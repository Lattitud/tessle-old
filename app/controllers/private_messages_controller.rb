class PrivateMessagesController < ApplicationController
  before_filter :authenticate_user!, only: [:private, :create, :private_chat]
  before_filter :correct_user, only: [:private]

  def create
    # No redirect or render makes it an AJAX request
    @private_message = current_user.private_messages.build(params[:private_message])

    if @private_message.save
      MsgWorker.perform_async(params[:private_message][:id], params[:private_message][:recipient_id], 'private', current_user.id, params[:private_message][:content])
      NotificationWorker.perform_async(@private_message.id, current_user.id, true)

      # This variable is needed for create.js.erb
      @recipient_id = params[:private_message][:recipient_id]

      # This is the pusher server action for the notification
      Pusher.trigger_async("private-#{@recipient_id}}", 'new_notification', {
        :id => current_user.id,
        :from => current_user.user_name
      })

      
    else
      # Error catch for bad private messages
    end
  end

  def private
    @recipients = User.find_last_conversations(current_user, 5)
  end

  def private_chat
    @recipient = User.find_by_slug!(params[:id])
    @recipient_id = @recipient.id
    @presence_suffix = get_presence_suffix(current_user.id, @recipient_id)

    @past_private_messages = current_user.show_last_conversation(@recipient_id, 15).reverse
    # Mark all messages as read when private_chat initiated
    NotificationWorker.perform_async(@recipient_id, current_user.id, false)

    # Private chats are found by -
    # write_chat_cookie("private-#{@recipient_id}")
    user_session.add_chat(@recipient_id)
  end

  def remove_chat
    @recipient_id = User.find_by_slug!(params[:id]).id
    user_session.remove_chat(@recipient_id)
  end

  private
    def correct_user
      @user = User.find_by_slug!(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
end