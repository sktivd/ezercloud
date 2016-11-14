class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #before_action :authorize
  before_action :authenticate_account!
  
  helper_method :administrator?, :all_equipment, :authorized_equipment
    
  protected
  
    def authorized_to? role, resource
      current_account and (current_account.is_admin? or current_account.has_role?(role, resource))
    end
    
    def current_user
      current_account
    end
    
    def check_account role, resource
      if not authorized? role, resource
        redirect_to root_path, notice: "Access not allowed"
      end
    end
    
#    def current_roles
#      @current_roles ||= current_account.roles.to_a if current_account
#    end
#    
#    def authorize
#      if not logged_in?
#        redirect_to login_path(redirect_to: params), notice: notice || "Please log in"
#      elsif not current_account.authorized
#        redirect_to authorize_path, notice: notice || "Account should be confirmed"
#      end
#    end
#    
#    def allow_only_to privilege
#      # super users are always allowed!
#      unless current_account.privilege_super or current_account.instance_eval("privilege_" + privilege.to_s)
#        redirect_to root_path, method: :get, notice: "Not allowed!"
#      end
#    end
    
    def administrator?
      current_account and current_account.is_admin?
    end
    
    def all_equipment
      @all_equipment ||= Equipment.order(:equipment)
    end
    
    def authorized_equipment
      @authorized_equipment ||= policy_scope(Equipment)
    end
    
  private
  
    def search_authorized_equipment_of account
      aequipment = []
      all_equipment.each do |equipment|
        aequipment << equipment if Equipment.with_role?(:viewer, current_account) or administrator?
      end
      
      aequipment
    end
    
end
