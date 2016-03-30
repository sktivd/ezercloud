class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authorize
  
  helper_method :current_user, :logged_in?, :administrator?, :all_equipment, :authorized_equipment
    
  protected
  
    def current_user
      @current_user ||= User.find_by(id: session[:user_id])
    end
    
    def logged_in?
      current_user != nil
    end
    
    def authorize
      if not logged_in?
        redirect_to login_path(redirect_to: params), notice: notice || "Please log in"
      elsif not current_user.authorized
        redirect_to authorize_path, notice: notice || "Account should be confirmed"
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
    
    def authorized_equipment
      @authorized_equipment ||= search_authorized_equipment_of current_user
    end
    
    rescue_from ActionController::InvalidAuthenticityToken do 
      session[:user_id] = nil
      redirect_to login_path, notice: "Session Timeout"
    end

  private
  
    def search_authorized_equipment_of user
      aequipment = []
      all_equipment.each do |equipment|
        aequipment << equipment if user[("equipment_" + equipment.db).to_sym] or administrator?
      end
      
      aequipment
    end
end
