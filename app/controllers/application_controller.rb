class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!
  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected
  def require_admin_user
    redirect_to root_path unless current_user.user_type.admin?
  end
  
  def require_manager_user
    redirect_to root_path unless current_user.user_type.manager?
  end
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :manager_id
    devise_parameter_sanitizer.for(:sign_up) << :full_name
  end
end
