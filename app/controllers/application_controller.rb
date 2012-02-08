class ApplicationController < ActionController::Base
  # protect_from_forgery
  before_filter :check_user
  
  private
  
  def check_user
    @current_user = User.find(session[:current_user]) rescue nil
    if controller_name == "auth" or controller_name == "pages" or controller_name == "callback"
      return true
    end
    if @current_user.blank?
      session[:redirect_to] = request.fullpath
      redirect_to "/auth/login"
    end
  end
  
end
