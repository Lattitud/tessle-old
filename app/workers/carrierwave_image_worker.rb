class CarrierwaveImageWorker
  include Sidekiq::Worker
  sidekiq_options queue: "carrierwave_image"
  # sidekiq_options retry: false

  def perform(post_id, direct_upload_url)
    post = Post.find(post_id)
    post.update_attribute(:remote_image_url, direct_upload_url)
  end

end