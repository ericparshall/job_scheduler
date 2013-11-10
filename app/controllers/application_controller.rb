class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!
  
  private
  def require_admin_user
    redirect_to root_path unless current_user.admin?
  end
end
