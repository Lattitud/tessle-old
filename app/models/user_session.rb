class UserSession
  def initialize(session)
    @session = session
    @session[:chat_ids] ||= []
  end

  def add_chat(chat_suffix)
    @session[:chat_ids] << chat_suffix unless @session[:chat_ids].include?(chat_suffix)
  end

  def remove_chat(chat_suffix)
    @session[:chat_ids].delete(chat_suffix)
  end

  def get_chat_session
    @session[:chat_ids]
  end
end