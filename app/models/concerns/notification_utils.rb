module NotificationUtils
  extend ActiveSupport::Concern  
  
  def generate_notification params
    @notification = Notification.new(follow: Notification::TYPES[params[:follow]], tag: params[:tag], message: params[:message], user_id: params[:user].id, data: params[:data].to_json, mailer: params[:mailer], expired_at: params[:expired_at])
    @notification.authentication_key = Digest::SHA256.hexdigest @notification.to_s
    
    if @notification.save
      @notification.set_url(params[:path], params[:method], params[:parameters])
      @notification.save
      if @notification.follow == Notification::TYPES[:response] and @notification.mailer
          @notification.email
      end
      @notification
    end
  end
  
  def notification
  end
end