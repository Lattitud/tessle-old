module SessionsHelper
  # def sign_in(user)
  #   # Each element in the cookie is a hash of 2 elements, a 'value' and optional 'expires'
  #   # .permanent added method to Cookie class, automatically sets 20.years.from_now
  #   cookies.permanent[:remember_token] = user.remember_token

  #   # Creates current_user, accessible in controllers and views
  #   # 'self.current_user = ...'  is converted to 'current_user=(...)'
  #   self.current_user = user
  # end

  def signed_in?
    user_signed_in?
  end
  
  # def current_user=(user)
  #   @current_user = user
  # end

  # Finding current user using remember_token
  # def current_user
  #   # '||=' Set @current_user to remember token, only if @current_user is undefined
  #   @current_user ||= User.find_by_remember_token(cookies[:remember_token])
  # end

  def current_user?(user)
    user == current_or_guest_user
  end

  def guest_user?(user)
    user.user_name.include?("guest") && user.email.include?("guest")
  end

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end

  # def write_chat_cookie(chat_id)
  #   unless !cookies[:chat_ids].blank? && cookies[:chat_ids].to_s.split(',').include?(chat_id.to_s)
  #     cookies[:chat_ids] = cookies[:chat_ids].to_s.split(',').push(chat_id.to_s).join(',')
  #   end
  # end

  # def read_chat_cookie
  #   cookies[:chat_ids].to_s.split(',')
  # end
  
  def parse_for_user_id(chat_suffix)
    chat_arr = chat_suffix.to_s.split("-")
    chat_arr[1].to_i
  end

  def parse_for_post_id(chat_suffix)
    chat_arr = chat_suffix.to_s.split("_")
    chat_arr[1].to_i
  end

  def parse_for_tessle_id(chat_suffix)
    chat_arr = chat_suffix.to_s.split("=")
    chat_arr[1].to_i    
  end

  def get_presence_suffix(first_id, second_id)
    if first_id.to_i > second_id.to_i
      "#{first_id}-#{second_id}"
    else
      "#{second_id}-#{first_id}"
    end    
  end
  # def signed_in_user
  #   unless signed_in?
  #     store_location
  #     redirect_to signin_url, notice: "Please sign in."
  #   end
  # end
  
  # def sign_out
  #   self.current_user = nil
  #   cookies.delete(:remember_token)
  # end

  # def redirect_back_or(default)
  #   redirect_to(session[:return_to] || default)
  #   session.delete(:return_to)
  # end

  # def store_location
  #   session[:return_to] = request.url
  # end
  
end
