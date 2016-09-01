class Accounts::InvitationsController < Devise::InvitationsController
  before_action :configure_account_update_params if :devise_controller?
  
  protected
  
  # If you have extra params to permit, append them to the sanitizer.
    def configure_account_update_params
      devise_parameter_sanitizer.permit(:account_update, keys: [:name])
    end
    
end
