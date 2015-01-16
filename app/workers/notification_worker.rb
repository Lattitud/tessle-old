class NotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: "notification"
  # sidekiq_options retry: false

  def perform(sender_id, recipient_id, sent_bool)
    current_user = User.find(recipient_id)

    if sent_bool
      # In this case sender_id is the Private Message
      private_message = PrivateMessage.find(sender_id)

      private_message.mark_as_read! :for => current_user
    else
      pm_list = PrivateMessage.where("sender_id = :sender_id AND recipient_id = :recipient_id", {sender_id: sender_id, recipient_id: recipient_id})
      PrivateMessage.mark_as_read! pm_list.to_a, :for => current_user
    end
  end

end