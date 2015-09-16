class SessionsController < ApplicationController
  skip_before_action :authorize
  
  def new
    if logged_in?
      redirect_to diagnoses_path
    end
  end

  def create
    user = User.find_by(name: params[:login][:name])
    if user and user.authenticate(params[:login][:password])
      session[:user_id] = user.id
      redirect_to diagnoses_path
    else
      redirect_to login_path, alert: "Invalid user/password combination"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Logged out"
  end
end
