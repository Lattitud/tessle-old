class MsgWorker
  include Sidekiq::Worker
  sidekiq_options queue: "msg"
  # sidekiq_options retry: false

  def perform(message_id, messageable_id, messageable_type, sender_id, content)
    current_user = User.find(sender_id)
    filtered_message = CGI::escapeHTML(content)

    if messageable_type == 'private'
      html = "<li id='private_message#{message_id}'>"
      html += "<div id='private_message#{message_id}_div' class='other_user_message'>"
      html += "<a href='/users/#{current_user.id}' class='mini-avatar-link'><img src='#{current_user.avatar.url(:mini)}'></a>"
      html += "<div class='message-div'><p>#{filtered_message}</p>"
      html += "<p class='message-details'>#{current_user.user_name}</p></div></div></li>"

      # Messageable_id = recipient_id in this case
      presence_suffix = get_presence_suffix(current_user.id, messageable_id)
      channel = "presence-private-#{presence_suffix}"

      # This is the pusher server action for the private message
      Pusher.trigger_async(channel, 'new_private_message', {
        :id => current_user.id,
        :private_message_id => message_id,
        :from => current_user.user_name,
        :html => html
      })


    elsif messageable_type == 'post'
      html = "<li id='message#{message_id}'><div id='message#{message_id}_div' class='other_user_message'>"
      html += "<a href='/users/#{current_user.id}' class='mini-avatar-link'><img src='#{current_user.avatar.url(:mini)}'></a>"
      html += "<div class='message-div'><p>#{filtered_message}</p><p class='message-details'>#{current_user.user_name} &#8226"
      html += "</p></div></li>"

      channel = "presence-post-#{messageable_id}"

      # Pusher server action
      Pusher.trigger_async(channel, 'new_post_message', {
        :id => messageable_id,
        :message_id => message_id,
        :sender_id => sender_id,
        :html => html
      })
    else
      channel = "presence-tag-#{messageable_id}"
      Pusher.trigger_async(channel, 'new_tag_message', {
        :id => messageable_id,
        :message_id => message_id,
        :html => html
      })
    end

  end

  private
    def get_presence_suffix(first_id, second_id)
      if first_id.to_i > second_id.to_i
        "#{first_id}-#{second_id}"
      else
        "#{second_id}-#{first_id}"
      end    
    end

end