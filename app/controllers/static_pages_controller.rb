class StaticPagesController < ApplicationController
  helper_method :current_or_guest_user

  def home
    if user_signed_in?
      # @feed_items = current_user.feed.where("created_at > ?", 7.days.ago).order("score DESC").paginate(page: params[:page], per_page: 20)
      # @trending_tags = Tag.order("score DESC").limit(10)
      # @recipients = User.find_last_conversations(current_user, 5)

      # unless @feed_items.any?
        @feed_items = Post.where("created_at > ? AND score > 1", 4.days.ago).order("score DESC").paginate(page: params[:page], per_page: 20)
      # end

      # For the new post
      @post = Post.new


    else
      # User not signed in
      @feed_items = Post.where("created_at > ? AND score > 1", 4.days.ago).order("score DESC").paginate(page: params[:page], per_page: 20)

      @post = Post.new # Temporary fix for non users
    end
    
    # @top_ten_posts = Post.top_ten
    # @trending_tags = Tag.order("score DESC").limit(10)
  end

  # def signup
  #   if signed_in?
  #     flash[:notice] = "You are already signed in."
  #     redirect_to root_url
  #   end
  # end

  # def signin
  #   if signed_in?
  #     flash[:notice] = "You are already signed in."
  #     redirect_to root_url
  #   end
  # end

  # def welcome
  # end

  # def help
  # end

  # def about
  # end

  # def contact
  # end

  # def stats
  #   @top_ten_contributors = User.top_ten
  # end

end
