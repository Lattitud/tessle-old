# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :confirmable #, :validatable

  # Setup accessible (or protected) attributes for your model
  # attr_accessible are protected from XSS
  attr_accessible :email, :user_name, :password, :password_confirmation, :avatar, :remember_me, :login, :slug, :provider, :uid, :remote_avatar_url, :direct_upload_url, :crop_x, :crop_y, :crop_w, :crop_h, :current_password
  attr_accessor :login, :crop_x, :crop_y, :crop_w, :crop_h, :current_password

  mount_uploader :avatar, AvatarUploader
  # process_in_background :avatar # Used for carrierwave backgrounder

  acts_as_reader
  acts_as_voter
  # The following line is optional, and tracks karma (up votes) for questions this user has submitted.
  # Each question has a submitter_id column that tracks the user who submitted it.
  # The option :weight value will be multiplied to any karma from that voteable model (defaults to 1).
  # You can track any voteable model.
  has_karma(:posts, :as => :user, :weight => 10)

  # dependent: :destroy makes posts destroyed when user destroyed
  has_many :posts, dependent: :destroy
  has_many :messages, dependent: :destroy

  # Private Messages
  has_many :private_messages, class_name: "PrivateMessage", foreign_key: "sender_id", dependent: :destroy
  has_many :reverse_private_messages, class_name: "PrivateMessage", foreign_key: "recipient_id", dependent: :destroy

  # This is code for followers/followed for users
  has_many :user_relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :user_relationships, source: :followed
  has_many :reverse_user_relationships, foreign_key: "followed_id",
                                   class_name:  "UserRelationship",
                                   dependent:   :destroy
  has_many :followers, through: :reverse_user_relationships, source: :follower

  # This is code for tessles
  has_many :tessle_relationships, foreign_key: "user_id", dependent: :destroy
  has_many :tags, through: :tessle_relationships, source: :tag

  before_save { |user| user.email = email.downcase }
  before_validation :generate_slug
  after_create :follow_user

  VALID_USER_NAME_REGEX = /\A[a-z0-9_]+\z/i
  validates :user_name, presence: true, length: {minimum:3, maximum: 17}, uniqueness: {case_sensitive: false}, format: { with: VALID_USER_NAME_REGEX}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: {case_sensitive: false}
  validates :slug, uniqueness: true, presence: true
  # VALID_PASSWORD_REGEX = /\d/
  # validates :password, length: { minimum: 7 }, format: { with: VALID_PASSWORD_REGEX }
  # validates :password, length: { minimum: 7 }

  scope :top_ten,
    select("users.id, users.user_name, users.avatar, count(posts.id) AS posts_count").joins(:posts).group("users.id").order("posts_count DESC").limit(10)

  def name
    user_name
  end

  def to_param
    slug
  end

  def generate_slug
    self.slug ||= user_name.parameterize
  end

  def feed
    Post.from_tags_tessled_by(self)
    # Post.from_users_followed_by(self)
  end

  # Following users -------------------------------------------
  def following_user?(other_user)
    self.user_relationships.find_by_followed_id(other_user.id)
  end

  def follow!(other_user)
    self.user_relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    self.user_relationships.find_by_followed_id(other_user.id).destroy
  end

  def follow_user
    # Dasun and Patrick will follow all new users
    if User.exists?(1)
      User.find(1).follow!(self) unless self.email.include?("guest") && self.user_name.include?("guest")
    end
    if User.exists?(2)
      User.find(2).follow!(self) unless self.email.include?("guest") && self.user_name.include?("guest")
    end
  end

  # Following tags ---------------------------------------------
  def following_tessle?(tag)
    self.tessle_relationships.find_by_tag_id(tag.id)
  end

  def tessle!(tag)
    self.tessle_relationships.create!(tag_id: tag.id)
  end

  def untessle!(tag)
    self.tessle_relationships.find_by_tag_id(tag.id).destroy
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(user_name) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def chatted_posts
    Post.from_user_chatted_by(self)
  end

  def show_last_conversation(recipient_id, number)
    PrivateMessage.show_last_messages(self.id, recipient_id, number)
  end

  def self.find_last_conversations(user, number)
    recipient_ids = "SELECT DISTINCT recipient_id FROM (SELECT recipient_id FROM private_messages WHERE sender_id = :user_id ORDER BY created_at DESC) AS recipients LIMIT #{number}"
    sender_ids = "SELECT DISTINCT sender_id FROM (SELECT sender_id FROM private_messages WHERE recipient_id = :user_id ORDER BY created_at DESC) AS senders LIMIT #{number}"
    where("id IN ((#{recipient_ids}) UNION ALL (#{sender_ids}))", user_id: user.id)
    # where(":user_id = private_messages.sender_id OR :user_id = private_messages.recipient_id", user_id: user.id).joins(:private_messages).group("users.id, private_messages.created_at").order("private_messages.created_at DESC").limit(number)
  end

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    if user
      return user
    else
      registered_user = User.where(:email => auth.info.email).first
      if registered_user
        return registered_user
      else
        user = User.create(user_name:auth.extra.raw_info.username,
          provider:auth.provider,
          uid:auth.uid,
          email:auth.info.email,
          # password:Devise.friendly_token[0,20])
          remote_avatar_url: auth.info.image)
      end

    end
  end

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(:provider => access_token.provider, :uid => access_token.uid ).first
    if user
      return user
    else
      registered_user = User.where(:email => access_token.info.email).first
      if registered_user
        return registered_user
      else
        user = User.create(user_name: data["email"][0..data["email"].index("@")-1],
          provider:access_token.provider,
          email: data["email"],
          uid: access_token.uid,
          remote_avatar_url: access_token.info.image)
          # password:Devise.friendly_token[0,20])
      end
    end
  end

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.user_name = auth.info.nickname
      user.email = auth.uid + "@twitter.com"
      # user.password = Devise.friendly_token[0,20]
      user.remote_avatar_url = auth.info.image.sub("_normal", "")
    end
  end

  # Also used for Omniauth
  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end


  # Used for password updating and bypass for social login
  def password_required?
    super && provider.blank?
  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end

  #  def password_match?
  #   self.errors[:password] << "can't be blank" if password.blank?
  #   self.errors[:password_confirmation] << "can't be blank" if password_confirmation.blank?
  #   self.errors[:password_confirmation] << "does not match password" if password != password_confirmation
  #   password == password_confirmation && !password.blank?
  # end

  # def update_without_password(params={})
  #   params.delete(:current_password)
  #   super(params)
  # end

end
