class MessagesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_messageable, only: [:chat]

  # For guest users
  skip_before_filter :verify_authenticity_token, :only => [:chat, :create]

  def create
    # No redirect or render makes it an AJAX request
    post_bool = params[:messageable_type] == "post"
    if post_bool
      @messageable = Post.find(params[:messageable_id])
    else
      @messageable = Tag.find(params[:messageable_id])
    end

    @message = @messageable.messages.build(params[:message])

    if @message.save
      # These 2 variables are needed for create.js.erb
      @messageable_type_lower = params[:messageable_type]
      @messageable_id = params[:messageable_id]

      MsgWorker.perform_async(@message.id, @messageable_id, @messageable_type_lower, current_or_guest_user.id, @message.content)      
    else
      # Error catch for bad messages
    end
  end

  def chat
    @past_messages = Message.previous_10(@messageable_id, @messageable_type).reverse
    @messageable_type_lower = @messageable_type.downcase

    if @messageable_type == 'Post'
      # Consider making these asynchronous process
      # write_chat_cookie("#{@messageable_type_lower}_#{@messageable_id}")
      current_or_guest_user.vote_for(@messageable) unless current_or_guest_user.voted_on?(@messageable)

      CalcScoreWorker.perform_async(@messageable_id, @messageable_type)

      if user_signed_in?
        TessleWorker.perform_async(@messageable_id, current_or_guest_user.id)
      end
    else 
      # write_chat_cookie("#{@messageable_type_lower}=#{@messageable_id}")
    end
  end


  # def like
  #   @message = Message.find(params[:id])
  #   current_user.vote_for(@message)
  # end

  # def unlike
  #   @message = Message.find(params[:id])
  #   current_user.unvote_for(@message)
  # end

  private
    def load_messageable
      resource, id = request.path.split('/')[1, 2]
      @messageable = resource.classify.constantize.find(id)
      @messageable_id = @messageable.id
      @messageable_type = @messageable.class.name
    end
end
