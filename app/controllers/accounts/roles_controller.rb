class Accounts::RolesController < ApplicationController
  include NotificationMethods
  
  helper_method :devise_mapping
  
  before_action :set_account, only: [:new, :get_fields, :propose, :grant, :destroy]
  before_action do
    authorize @account, :manage?
  end
  before_action :new_role, only: [:new, :propose, :grant]
  before_action :set_role, only: [:destroy]
  
  def new
    if @role.tag && Notification.find_by(tag: 'RoleGrant_' + @role.tag.split('_')[1])
      redirect_to root_path, notice: 'Requested role had already processed!'
    end
  end
  
  def get_fields
    @role       = { role: params[:role].to_sym }
    @selections = { fields: Account::FIELDS[@role[:role]], option: Account::OPTIONS[@role[:role]] }
    
    respond_to do |format|
      format.js
    end    
  end
  
  def propose 
    respond_to do |format|
      tag  = 'Role_' + Digest::SHA256.hexdigest([@account.id, @role, Date.today].join)
      
      if Notification.find_by(tag: @tag).nil?
        @data = { tag: tag, name: @account.name, email: @account.email, role: @role.role.to_sym, field: @role.field.nil? ? nil : @role.field.to_sym, from: @role.from, to: @role.to, location: @role.location }
        notifications = Account.with_role(:admin).map do |account|
          { follow: :responses, tag: tag, message: "A role is requested by #{@account.email}.\nPlease check!", every: 1.day, expired_at: 3.day.from_now, data: @data, account: account, redirect_path: '/accounts/roles/new', query: { account: { id: @account.id }, role: @data }, mailer: "role_request" }
        end
        
        send_notification notifications
        format.html { redirect_to account_path(current_account), notice: 'Request was successfully sent.' }
        format.json { render json: @data, status: :created, location: data }
      else
        format.html { redirect_to account_path(current_account), notice: 'The role had been already requested.' }
        format.json { render json: @tag, status: :unprocessable_entity  }
      end    
    end
  rescue NotificationError => e
    respond_to do |format|
      format.html { redirect_to account_path(current_account), notice: e.msg }
      format.json { render json: e.errors, status: :unprocessable_entity  }
    end
  end
  
  def grant
    tag = (@role.tag && @role.tag.size > 0) ? 'RoleGrant_' + @role.tag.split('_')[1] : 'RoleGrant_' + Digest::SHA256.hexdigest([@account.id, @role, Date.today].join)
    if Notification.find_by(tag: tag)
      redirect_to root_path, notice: 'Requested role had already processed!'
    end
    
    @data = { tag: tag, name: @account.name, email: @account.email, role: @role.role.to_sym, field: @role.field.nil? ? nil : @role.field.to_sym, from: @role.from, to: @role.to, location: @role.location, note: @role.note }

    respond_to do |format|
      if params[:accept]
        @message = "Requested role is accepted."
        @mailer  = "role_accepted"
      
        name   = @role.role.to_sym
        Account::MODELS[@role.field.to_sym].each do |model|
          role = @account.add_role name, model
          role.update_attributes(from: @role.from, to: @role.to, location: @role.location) if @role.from or @role.to or @role.location
        end
      else
        @message = "Requested role is declined."
        @mailer  = "role_declined"
      end
    
      send_notification [{ follow: :notices, tag: tag, message: @message, expired_at: 7.day.from_now, data: @data, account: @account, query: { role: @data }, mailer: @mailer }]        
      format.html { redirect_to root_path, notice: 'Requested role has been processed successfully.' }
      format.json { render json: @data, status: :created, location: @data }
    end
  rescue ActiveRecord::RecordInvalid => invalid
    respond_to do |format|
      format.html { redirect_to account_path(current_account), notice: invalid.record.errors }
      format.json { render json: invalid.record.errors, status: :unprocessable_entity  }
    end
  rescue NotificationError => e
    respond_to do |format|
      format.html { redirect_to account_path(current_account), notice: e.msg }
      format.json { render json: e.errors, status: :unprocessable_entity  }
    end
  end
  
  def destroy
    @account.remove_role @role.name, Object.const_get(@role.resource_type)
    respond_to do |format|
      format.html { redirect_to account_path(@account), notice: 'Role was successfully removed.' }
      format.json { head :no_content }
    end
  end
  
  private
    
    def set_account
      @account = Account.find(params[:account][:id])
    end
    
    def role_params
      params.require(:role).permit(:tag, :role, :field, :from, :to, :location, :note) if params[:role]
    end
    
    def new_role
      @role = Role.new(role_params)
      @role.role = @role.role.to_sym if @role.role
    end
    
    def set_role
      @role = Role.find(params[:role][:id])
    end
end
