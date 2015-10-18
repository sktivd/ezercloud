class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authorize
  
  helper_method :current_user, :logged_in?, :administrator?, :all_equipment
  
  protected
  
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  
  def logged_in?
    current_user != nil
  end
  
  def authorize
    unless logged_in?
      redirect_to login_path(redirect_to: params), method: :get, notice: "Please log in"
    end
  end
  
  def allow_only_to privilege
    # super users are always allowed!
    unless current_user.privilege_super or current_user.instance_eval("privilege_" + privilege.to_s)
      redirect_to root_path, method: :get, notice: "Not allowed!"
    end
  end
  
  def administrator?
    current_user and current_user.privilege_super
  end
  
  def all_equipment
    @all_equipment ||= Equipment.order(:equipment)
  end
end
