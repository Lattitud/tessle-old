class Tag < ActsAsTaggableOn::Tag

  def self.top_tags_not_followed_by(user)
    followed_tags = "SELECT tessle_relationships.tag_id FROM tessle_relationships WHERE user_id = :user_id"
    select("tags.id, tags.name, count(taggings.id) AS tag_count").where("tags.id NOT IN (#{followed_tags})", user_id: user.id).joins(:taggings).group("tags.id").order("tag_count DESC").limit(10)
  end

end