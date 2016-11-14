class Accounts::DevicesController < ApplicationController
  include NotificationMethods
  
  before_action :set_account, only: [:new, :propose, :grant, :decline]
  before_action except: [:autocomplete_sn] do
    authorize @account, :manage?
  end
  before_action :set_device_license, only: [:new, :propose, :grant, :decline]
  
  def new
    if @device_license.tag and Notification.find_by(tag: 'DeviceGrant_' + @device_license.tag.split('_')[1])
      redirect_to root_path, notice: 'Registering device had already processed!'
    end
  end
  
  def propose
    respond_to do |format|
      tag  = 'Device_' + Digest::SHA256.hexdigest([@account.id, @device_license, Date.today].join)
      
      if Notification.find_by(tag: @tag).nil?
        @data = { tag: tag, name: @account.name, email: @account.email, equipment_id: @device_license.equipment_id, serial_number: @device_license.serial_number, activated_at: @device_license.activated_at }
        notifications = Account.with_role(:admin).map do |account|
          { follow: :responses, tag: tag, message: "#{@account.email} had requested to register the device #{@data[:serial_number]}. \nPlease check!", every: 1.day, expired_at: 3.day.from_now, data: @data, account: account, redirect_path: '/accounts/devices/new', query: { account: { id: @account.id }, device_license: @data }, mailer: "device_request" }
        end
        
        send_notification notifications
        format.html { redirect_to account_path(current_account), notice: 'Request was successfully sent.' }
        format.json { render json: @data, status: :created, location: data }
      else
        format.html { redirect_to account_path(current_account), notice: 'The device had been already requested.' }
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
    tag = @device_license.tag ? 'DeviceGrant_' + @device_license.tag.split('_')[1] : 'DeviceGrant_' + Digest::SHA256.hexdigest([@account.id, @device_license, Date.today].join)
    if Notification.find_by(tag: tag)
      redirect_to root_path, notice: 'Requested device had already processed!'
    end
    
    @data = { tag: tag, name: @account.name, email: @account.email, equipment_id: @device_license.equipment_id, serial_number: @device_license.serial_number, activated_at: @device_license.activated_at, note: @device_license.note }
    
    respond_to do |format|
      if params[:accept]          
        message = "Requested device had been registered."
        mailer  = "device_accepted"
        @device_license.owner = @account
        @device_license.save!       
      else
        message = "Requested device had not been registered."
        mailer  = "device_declined"
      end
        
      send_notification [{ follow: :notices, tag: tag, message: message, expired_at: 7.day.from_now, data: @data, account: @account, query: { device: @data }, mailer: mailer }]
      format.html { redirect_to root_path, notice: 'Requested device has been processed successfully.' }
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
  
  def decline    
    respond_to do |format|
      if @device_license.update(deactivated_at: DateTime.now)
        format.html { redirect_to account_path(current_account.id), notice: 'Device was successfully deactivated.' }
        format.json { head :no_content }
      end
    end
  end
  
  def autocomplete_sn
    render json: Device.search(params[:term], {
      fields: ["serial_number"],
      limit: 10,
      load: false,
      misspellings: { below: 0 },
      where: {
        equipment_id: params[:equipment_id]
      }
    }).map(&:serial_number)
  end
  
  private
  
    def set_account
      @account = Account.find(params[:account][:id])
      
      # check admin
      if @account.is_admin?
        redirect_to :back, notice: "Administrator does not need any role!"          
      end
      @account
    rescue ActionController::RedirectBackError
      redirect_to root_path, notice: "Administrator does not need any role!"
    end
      
    def device_license_params
      params.require(:device_license).permit(:tag, :equipment_id, :serial_number, :activated_at, :note) if params[:device_license]
    end
    
    def set_device_license
      @device_license = @account.devices.build(device_license_params)
    end
        
end
