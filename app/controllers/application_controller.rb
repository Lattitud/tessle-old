class ApplicationController < ActionController::Base
  protect_from_forgery
  # All helpers are available in views but not controllers
  include SessionsHelper
  helper_method :notifications
  helper_method :user_session
  helper_method :current_or_guest_user

  # Force signout to prevent CSRF attacks
  # def handle_unverified_request
  #   sign_out
  #   super
  # end

  # Guest users
  # if user is logged in, return current_user, else return guest_user
  def current_or_guest_user
    if current_user
      if session[:guest_user_id]
        logging_in
        guest_user.destroy
        session[:guest_user_id] = nil
      end
      current_user
    else
      guest_user
    end
  end

  # find guest_user object associated with the current session,
  # creating one as needed
  def guest_user
    # Cache the value the first time it's gotten.
    @cached_guest_user ||= User.find(session[:guest_user_id] ||= create_guest_user.id)

  rescue ActiveRecord::RecordNotFound # if session[:guest_user_id] invalid
     session[:guest_user_id] = nil
     guest_user
  end


  def tag_tokens(query)
    @tags = ActsAsTaggableOn::Tag.all
    @tags = @tags.select { |v| v.name =~ /#{query}/i }
    @exact = @tags.select { |vv| vv.name =~ /\b#{query}\b/i }
    if @tags.empty?
      [{id: "<<<#{query}>>>", name: "New: \"#{query}\""}]
    else
      if @exact.empty?
        @existing_tags = @tags.map{ |t| {:id => t.name, :name => t.name}}
        [{id: "<<<#{query}>>>", name: "New: \"#{query}\""}] + @existing_tags
      else 
        @tags.map{ |t| {:id => t.name, :name => t.name}}
      end
    end
  end

  private
    def notifications
      @unread_count ||= PrivateMessage.where("recipient_id = :recipient_id", recipient_id: current_user.id).unread_by(current_user).count
    end
    
    def user_session
      @user_session ||= UserSession.new(session)
    end

    # called (once) when the user logs in, insert any code your application needs
    # to hand off from guest_user to current_user.
    def logging_in
      # For example:
      # guest_messages = guest_user.messages.all
      # guest_messages.each do |message|
      #   message.user_id = current_user.id
      #   message.save!
      # end
    end

    def create_guest_user
      random_token = "#{Time.now.to_i}#{rand(99)}"
      slug = "guest#{random_token}".parameterize
      u = User.create(:user_name => "guest#{random_token}", :email => "guest_#{random_token}@tessle.com", :slug => slug)
      u.save!(:validate => false)
      session[:guest_user_id] = u.id
      u
    end
    # helper_method :user_session
end
