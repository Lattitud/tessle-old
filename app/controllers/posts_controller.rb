class PostsController < ApplicationController
  before_filter :authenticate_user!, only: [:edit, :update, :new, :create, :destroy]
  before_filter :correct_user, only: [ :edit, :update, :destroy]
  before_filter :admin_user, only: []
  impressionist actions: [:show]

  def show
    @messageable_id = params[:id].to_i
    @messageable_type_lower = 'post'

    @post = Post.find(@messageable_id)
    # @top_messages = Message.top_messages(@messageable_id, 10)
    @past_messages = Message.previous_10(@messageable_id, 'Post').reverse

    CalcScoreWorker.perform_async(@messageable_id, 'Post')
    if user_signed_in?
      TessleWorker.perform_async(@messageable_id, current_user.id)
    end
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(params[:post])
    @post.add_tags={:tag_list => params[:post][:tag_list]}
    @post.parse_tag_list(params[:post][:tag_list])

    if @post.save
      CalcScoreWorker.perform_async(@post.id, 'Post')
      TessleWorker.perform_async(@post.id, current_user.id)

      if params[:post][:direct_upload_url].present?
        CarrierwaveImageWorker.perform_async(@post.id, params[:post][:direct_upload_url])
        flash[:notice] = "Processing post image..."
      else
        flash[:success] = "Your post has been successfully created!"
      end
      
      redirect_to current_user
    else
      # render 'new'
      redirect_to root_url
    end
  end

  def index
    if params[:tag]
      @title = params[:tag]
      @posts = Post.tagged_with(params[:tag]).paginate(page: params[:page])
      @past_messages = Message.previous_10(@messageable_id, 'Tag').reverse

      # Need to think about how to handle empty case
      @messageable_id = params[:id].to_i
      @messageable_type_lower = 'tag'
    else
      @title = "All Posts"
      # @posts = Post.text_search(params[:query]).paginate(page: params[:page])
      @posts = Post.all.paginate(page: params[:page])
    end
  end


  # Use these if you want to allow users to edit posts.
  # def edit
  # end

  # def update
  # end

  def destroy
    Post.find(params[:id]).destroy
    flash[:success] = "Post removed!"
    redirect_to current_user
  end

  def tags
    respond_to do |format|
      format.json{ render :json => tag_tokens(params[:q]) }
    end
  end

  def preview
    param_url = params[:url]
    doc = Nokogiri::HTML(open(param_url), nil, 'UTF-8')

    title = ""
    url = ""
    image_url = ""

    doc.xpath("//head//meta").each do |meta|
      if meta['property'] == 'og:title'
        title = meta['content']
      elsif meta['property'] == 'og:url'
        url = meta['content']
      elsif meta['property'] == 'og:image'
        image_url = meta['content']
      end
    end

    if title == ""
      title_node = doc.at_xpath("//head//title")
      if title_node
        title = title_node.text
      elsif doc.title
        title = doc.title
      else
        title = param_url
      end
    end


    if url == ""
      url = param_url
    end

    # Used for imgur thumbnail
    if url =~ /i.imgur/
      p_index = url.rindex(".")
      image_url = url[0..p_index-1] + "s" + url[p_index..-1]
    end
    
    render :json => {:title => title, :url => url, :image_url => image_url} and return

    if url =~ /i.imgur/
      p_index = url.rindex(".")
      image_url = url[0..p_index-1] + "s" + url[p_index..-1]
    end

    render :json => {:title => title, :url => url, :image_url => image_url} and return

  end

  private
    def correct_user
      unless current_user.admin?
        @post = current_user.posts.find_by_id(params[:id].to_i)
        redirect_to root_url if @post.nil?
      end
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
