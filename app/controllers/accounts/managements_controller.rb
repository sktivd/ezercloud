class Accounts::ManagementsController < ApplicationController
  include TimeMethods
  
  helper_method :in_seconds, :devise_mapping

  before_action only: [:index] do
    authorized_to? :manager, Account
  end
  before_action :set_account, only: [:show, :edit, :update, :destroy]
  before_action :account_params, only: [:update]
  
  # GET /accounts/managements
  def index
    @accounts = Account.order(:email).page(@page).per(20)
  end
  
  # GET /accounts/managements/:id
  def show
  end

  # GET /accounts/managements/:id/edit
  def edit
    @account.admin = @account.has_role? :admin
  end

  # PATCH/PUT /accounts/managements/:id
  def update
    if params[:account][:admin]
      @account.add_role :admin unless @account.has_role? :admin
    else
      @account.remove_role :admin if @account.has_role? :admin
    end
    
    respond_to do |format|
      if current_account.valid_password?(params[:account][:current_password]) and @account.update(account_params)
        format.html { redirect_to @account, notice: 'Account was successfully updated.' }
        format.json { render :show, status: :ok, location: @laboratory }
      else
        @account.errors[:current_password] = "please, input your password" unless current_account.valid_password?(params[:account][:current_password])
        format.html { render :edit }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/managements/:id
  def destroy
    @account.destroy
    respond_to do |format|
      format.html { redirect_to accounts_url, notice: 'Account was successfully removed.' }
      format.json { head :no_content }
    end
  end
    
  protected
  
    def devise_mapping
      @devise_mapping ||= request.env["devise.mapping"]
    end
  
    # If you have extra params to permit, append them to the sanitizer.
    def configure_account_update_parameters
      devise_parameter_sanitizer.permit(:account_update, keys: [:name])
    end

    def set_account
      @account = Account.find(params[:id])
    end
    
    def account_params
      params.require(:account).permit(:name)
    end 
    
end
