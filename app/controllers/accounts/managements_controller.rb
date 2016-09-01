class Accounts::ManagementsController < ApplicationController
  include TimeMethods
  
  helper_method :in_seconds, :devise_mapping
  
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
  end

  # PATCH/PUT /accounts/managements/:id
  def update
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
      devise_parameter_sanitizer.permit(:account_update, keys: [:name, :admin, :cover_area])
    end

    def set_account
      @account = Account.find(params[:id])
      @account.area_fields = @account.areas.join("\n")
    end
    
    def account_params
      STDERR.puts params
      if administrator?
        params[:account][:cover_area] = params[:account][:area_fields].tr("\n", "|")
        params.require(:account).permit(:name, :admin, :cover_area)
      else
        params.require(:account).permit(:name)
      end
    end 
    
end
