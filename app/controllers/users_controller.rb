class UsersController < ApplicationController
  before_filter :authenticate_user!, only: [:index, :edit, :update, :destroy]
  before_filter :correct_user,   only: [:edit]
  before_filter :admin_user,     only: [:destroy]
  before_filter :find_user, only: [:show, :destroy, :chatted, :followers, :following, :tags]

  def show
    # @user = User.find(params[:id])
    @posts = @user.posts.order("posts.id DESC").paginate(page: params[:page], per_page: 20)
  end

  def index
    @users = User.order("users.user_name ASC").paginate(page: params[:page], per_page: 50)
  end

  def destroy
    # User.find(params[:id]).destroy
    @user.destroy
    flash[:success] = "User destroyed."
    redirect_to users_url
  end

  def chatted
    @title = "chatted"
    # @user = User.find(params[:id])
    @chatted_posts = @user.chatted_posts.paginate(page: params[:page], per_page: 20)
    render 'show_chatted'
  end

  def followers
    @title = "followers"
    # @user = User.find(params[:id])
    @users = @user.followers.order("users.user_name ASC").paginate(page: params[:page], per_page: 20)
    render 'show_follow'
  end

  def following
    @title = "following"
    # @user = User.find(params[:id])
    @users = @user.followed_users.order("users.user_name ASC").paginate(page: params[:page], per_page: 20)
    render 'show_follow'
  end
  
  def tags
    @title = "tags"
    # @user = User.find(params[:id])
    if current_user?(@user)
      @suggested_tags = Tag.top_tags_not_followed_by(@user)
    end
    @tags = @user.tags.order("name ASC")
    render 'show_tags'
  end

  private
    def correct_user
      @user = User.find_by_slug!(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end

    def find_user
      @user = User.find_by_slug!(params[:id])
    end
  end
