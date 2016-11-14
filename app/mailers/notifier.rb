class Notifier < ApplicationMailer
  default from: 'no-reply@ezercloud.com', return_path: 'EzerCloud <skynet.201505@gmail.com>'
  
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.new_qcmaterial.subject
  #
  def new_qcmaterial notification
    @notification = notification
    @data = @notification.data
    mail to: @notification.account.email, subject: "EzerCloud: New QC material has been tested."
  end
  
  def role_request notification
    @notification = notification
    @data = @notification.data
    mail to: @notification.account.email, subject: "EzerCloud: #{@notification.account.name} has requested a role about #{@data[:role]}."
  end

  def role_accepted notification
    @notification = notification
    @data = @notification.data
    mail to: @notification.account.email, subject: "EzerCloud: requested role has been accepted."
  end

  def role_declined notification
    @notification = notification
    @data = @notification.data
    mail to: @notification.account.email, subject: "EzerCloud: requested role has been declined."
  end

  def device_request notification
    @notification = notification
    # @data = JSON.parse(@notification.data, symbolize_names: true)
    @data = @notification.data
    mail to: @notification.account.email, subject: "EzerCloud: #{@notification.account.name} has requested to register a device, #{Equipment.find(@data[:equipment_id]).equipment} #{@data[:serial_number]}."
  end

  def device_accepted notification
    @notification = notification
    @data = @notification.data
    mail to: @notification.account.email, subject: "EzerCloud: requested device has been registered."
  end

  def device_declined notification
    @notification = notification
    @data = @notification.data
    mail to: @notification.account.email, subject: "EzerCloud: requested device has been declined."
  end
      
#  def authorization notification
#    @notification = notification
#    @data = JSON.parse(@notification.data, symbolize_names: true)
#    mail to: @notification.account.email, subject: "EzerCloud: Account is required to be confirmed."    
#  end
end
