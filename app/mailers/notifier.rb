class Notifier < ApplicationMailer
  default from: 'QCtoolkit <skynet.201505@gmail.com>'
  
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.new_qcmaterial.subject
  #
  def new_qcmaterial(notification)
    @notification = notification
    @data = JSON.parse(@notification.data, symbolize_names: true)
    mail to: @notification.user.email, subject: "QCtoolkit: New QC material has been tested."
  end
end
