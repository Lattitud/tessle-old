class PusherController < ApplicationController
  protect_from_forgery :except => :auth # stop rails CSRF protection for this action

  def auth
    if current_user
      if params[:channel_name].include?("presence")
        response = Pusher[params[:channel_name]].authenticate(params[:socket_id], {
          :user_id => current_user.id,
          :user_info => {
            :name => current_user.user_name,
            :avatar => current_user.avatar_url(:mini)
          }
        })
      else
        response = Pusher[params[:channel_name]].authenticate(params[:socket_id])
      end
      
      render :json => response
    else
      render :text => "Not authorized", :status => '403'
    end
  end
end