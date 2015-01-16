class Post < ActiveRecord::Base
  attr_accessible :title, :url, :score, :tag_list, :image, :remote_image_url, :direct_upload_url
  belongs_to :user
  has_many :messages, as: :messageable, dependent: :destroy

  mount_uploader :image, ImageUploader
  # process_in_background :image # Used for carrierwave_backgrounder

  acts_as_taggable_on :tags
  acts_as_voteable
  is_impressionable

  validates :title, presence: true, length: { maximum: 70 }
  validates :user_id, presence: true
  validates :tag_list, presence: true
  validate :maximum_amount_of_tags
  validate :validate_image_fields

  # default_scope order: 'posts.score DESC'

  # ActiveRecord Callbacks
  after_find :calculate_score
  # before_create :default_values

  # Calculates new Gem score, might need to be optimized
  def calculate_score
    unless self.new_record?
      # ScoringPostsWorker.perform_async(self)
      # time_elapsed  = (Time.zone.now - self.created_at) / 3600
      # score = (self.votes_for) / ((time_elapsed + 2) ** (1.5))

      time_elapsed  = 1440 - ((Time.zone.now - self.created_at) / 60)
      score = (self.votes_for * 20) + time_elapsed
      self.update_attribute(:score, score)
    end
  end


  include PgSearch
  pg_search_scope :search, against: [:title],
    using: {tsearch: {dictionary: "english"}},
    associated_against: {tags: [:name]}

  scope :top_ten,
    select("posts.id, posts.title, posts.created_at, count(messages.id) AS messages_count").where("posts.created_at > ?", 3.days.ago).joins(:messages).group("posts.id").order("messages_count DESC").limit(10)


  # Search functionality
  # include PgSearch
  # pg_search_scope :search, against: [:title],
  #   using: {tsearch: {dictionary: "english"}},
  #   associated_against: {tags: [:name]}
  # def self.text_search(query)
  #   if query.present?
  #     search(query)
  #   else
  #     scoped
  #   end
  # end

  def to_param
    "#{id}-#{title}".parameterize
  end

  # Returns posts from the users being followed by the given user.
  # SELECT * FROM posts WHERE user_id IN (SELECT followed_id FROM post_relationships WHERE follower_id = 1) R user_id = 1
  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM user_relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id", 
          user_id: user.id)
  end

  def self.from_tags_tessled_by(user)
    taggable_ids = "SELECT t.taggable_id FROM tessle_relationships AS tr, taggings AS t WHERE tr.user_id = :user_id AND t.tag_id = tr.tag_id"
    followed_user_ids = "SELECT followed_id FROM user_relationships
                         WHERE follower_id = :user_id"

    where("id IN (#{taggable_ids}) OR user_id IN (#{followed_user_ids}) OR user_id = :user_id", user_id: user.id)

  end


  # Returns chatted posts from the user
  def self.from_user_chatted_by(user)
    where("posts.id = votes.voteable_id AND votes.voter_id = :user_id", user_id: user.id).joins(:votes).group("posts.id, votes.id").order("votes.id DESC")
  end


  def maximum_amount_of_tags
    number_of_tags = tag_list_cache_on("tags").uniq.length
    errors.add(:base, "Please only use up to 5 tessles") if number_of_tags > 5
  end

  # def url_or_image
  #   errors.add(:base, "Please only use url or an uploaded image, not both") if ( !remote_image_url.blank? and !image.blank?)
  # end

  def validate_image_fields
    if remote_image_url.present?
       # condition/validations for the url
    elsif image
       # condition/validations for uploaded image
    else
       errors.add(:base, "No image url or local image provided")
    end
  end

  def add_tags=(args)
    return if !args.is_a?(Hash)
    list = args[:tag_list]
    list.gsub!(/<<<(.+?)>>>/) { ActsAsTaggableOn::Tag.find_or_create_by_name(name: $1).name } if list
  end

  def parse_tag_list(list)
    self.tag_list = list
  end

  # private
  #   def default_values
  #     self.score ||= 1440
  #   end

end
