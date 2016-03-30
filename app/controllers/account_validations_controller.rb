class AccountValidationsController < ApplicationController
  include NotificationMethods
  
  skip_before_action :authorize
  before_action      :authorize_temporarily, only: [:inform, :resend]
  
  # get /authorize
  def inform
    if current_user.nil?
      redirect_to root_path, notice: 'Please login'
    end
    
    @notification = Notification.find_by(tag: 'P_' + current_user.email)
    @remained = @notification.expired_at - DateTime.now
  end

  # post /authorize
  def resend
    respond_to do |format|
      format.js do
        send_email_notification current_user.notification, replacement: true
      end
    end
  end
  
  # get /authorize/:id
  def confirm
    @user = User.find params[:id]
    unless @user.authorized 
      if @user.update(authorized: true)
        redirect_to login_path, notice: "Your account has been successfully confirmed."
      else
        redirect_to authorize_path, notice: "Authorization failed. You should contact to admin."      
      end
    else
      session[:user_id] = nil
      redirect_to login_path, notice: "Your account has been already confirmed."
    end
  rescue
    redirect_to root_path, notice: "Invalid account confirmation"
  end
   
  private
  
    def authorize_temporarily
      if not logged_in?
        redirect_to login_path(redirect_to: params), method: :get, notice: "Please log in"
      end
    end
end
