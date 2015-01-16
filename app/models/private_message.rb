class PrivateMessage < ActiveRecord::Base
  attr_accessible :sender_id, :recipient_id, :content

  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"

  validates :sender_id, presence: true
  validates :recipient_id, presence: true
  validates :content, presence: true

  acts_as_readable :on => :created_at

  def self.show_last_messages(sender_id, recipient_id, number)
    where("(sender_id = :sender_id AND recipient_id = :recipient_id) OR (sender_id = :recipient_id AND recipient_id = :sender_id)", {sender_id: sender_id, recipient_id: recipient_id}).order("id DESC").limit(number)
  end
end
