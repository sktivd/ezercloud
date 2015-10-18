# Preview all emails at http://localhost:3000/rails/mailers/notifier
class NotifierPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/notifier/new_qcmaterial
  def new_qcmaterial
    Notifier.new_qcmaterial
  end

end
