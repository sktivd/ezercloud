class UsersController < ApplicationController
  before_action only: [:index, :new] do
    allow_only_to :super
  end
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :match_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    if administrator?
      @authorized = true
    end
    
    if session[:authorized_password]
      # keep-in 3 minutes
      if Time.zone.now - session[:authorized_on].to_time < 3 * 60
        @authorized = true
      else
        session[:authorized_password] = nil
      end
    end
    
    if params[:change_mode] == 'password'
      @change_mode = 'password'
    else
      @change_mode = 'settings'
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if verify_recaptcha
        if @user.save
          format.html { redirect_to users_url, notice: "User #{@user.name} was successfully created." }
          format.json { render :show, status: :created, location: @user }
        else
          format.html { render :new }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if administrator? and current_user.id != @user.id
      respond_to do |format|
        if @user.update(user_params)
          format.html { redirect_to user_path(@user), notice: "User #{@user.name}'s #{params[:change_mode]} was successfully updated." }
        else
          format.html { redirect_to edit_user_path(@user, change_mode: params[:change_mode]), notice: "invalid settings" }
        end
      end
    else
      if session[:authorized_password]
        if params[:change_mode] == 'password'
          u_params = user_password_params
        else
          u_params = user_settings_params session[:authorized_password]
        end
        
        respond_to do |format|
          if @user.update(u_params)
            format.html { redirect_to user_path(@user), notice: "User #{@user.name}'s #{params[:change_mode]} was successfully updated." }
          else
            format.html { redirect_to edit_user_path(@user, change_mode: params[:change_mode]), notice: "invalid settings" }
          end
        end
      else
        if @user.authenticate(params[:user][:current_password])
          session[:authorized_password] = params[:user][:current_password]
          session[:authorized_on] = Time.zone.now
          redirect_to edit_user_path(@user, change_mode: params[:change_mode])
        else
          redirect_to user_path(@user), notice: "Password incorrect"
        end
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully removed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :password, :password_confirmation, :current_password, :full_name, :email, :privilege_super, :privilege_reagent, :privilege_notification, :equipment_frends)
    end

    def user_password_params
      params.require(:user).permit(:password, :password_confirmation, :current_password)
    end

    def user_settings_params password
      u_params = params.require(:user).permit(:current_password, :full_name, :email)
      u_params.merge(password: password, password_confirmation: password)
    end
    
    def match_user
      unless administrator? or current_user.id == @user.id
        redirect_to diagnoses_path, notice: "Inaccessible!"
      end
    end
    
end
