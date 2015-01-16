class Message < ActiveRecord::Base
  attr_accessible :content, :user_id, :messageable
  belongs_to :user
  belongs_to :messageable, polymorphic: true

  # acts_as_voteable

  validates :content, presence: true
  validates :user_id, presence: true

  def self.previous_10(messageable_id, messageable_type)
    where("messageable_id = :messageable_id AND messageable_type = :messageable_type", {messageable_id: messageable_id, messageable_type: messageable_type}).order("id DESC").limit(10)
  end

  # def self.top_messages(post_id, number)
  #   # Message.tally.group("votes.id").order("COUNT(votes.id) DESC").limit(10)
  #   where("messages.id = votes.voteable_id AND messages.messageable_id = :post_id AND messages.messageable_type = 'Post' AND votes.voteable_type = 'Message'", post_id: post_id).joins(:votes).group("messages.id").order("COUNT(messages.id) DESC").limit(number)
  # end
end
