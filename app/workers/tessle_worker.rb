class TessleWorker
  include Sidekiq::Worker
  sidekiq_options queue: "tessle"
  # sidekiq_options retry: false

  def perform(post_id, user_id)
    current_user = User.find(user_id)
    post = Post.find(post_id)

    post.tags.each { |tag| 
        current_user.tessle!(tag) unless current_user.following_tessle?(tag) }
  end

end