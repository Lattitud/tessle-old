class TessleRelationship < ActiveRecord::Base
  attr_accessible :tag_id, :user_id

  belongs_to :tag, class_name: "Tag"
  belongs_to :user, class_name: "User"

  validates :tag_id, presence: true
  validates :user_id, presence: true
end
