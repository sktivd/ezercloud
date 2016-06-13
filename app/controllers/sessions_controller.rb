class SessionsController < ApplicationController
  protect_from_forgery
  skip_before_action :verify_authenticity_token, if: :json_request?
  skip_before_action :authorize
    
  def new
    if logged_in?
      redirect_to root_path
    end
    session[:redirect_to] = params[:redirect_to]
  end

  def create
    user = User.find_by(name: params[:login][:name])
    if user and user.authenticate(params[:login][:password])
      session[:user_id] = user.id
      
      if session[:redirect_to]
        the_path = session[:redirect_to]
        session[:redirect_to] = nil
        redirect_to the_path, notice: "Logged in" 
      else
        redirect_to root_path, notice: "Logged in"
      end
    else
      # keep redirect_to information
      redirect_to login_path(redirect_to: session[:redirect_to]), notice: "User name or password is incorrect."
    end
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Logged out"
  end
    
  private
  
    def json_request?
      request.format.json?
    end
end
