module NotificationUtils
  extend ActiveSupport::Concern  
  
  def generate_notification params
    @notification = Notification.new(follow: Notification::TYPES[params[:follow]], tag: params[:tag], message: params[:message], user_id: params[:user].id, data: params[:data].to_json, expired_at: params[:expired_at])
    @notification.authentication_key = Digest::SHA256.hexdigest @notification.to_s

    if @notification.save
      if @notification.follow == Notification::TYPES[:response]
        @notification.set_url(params[:path], params[:method], params[:parameters])
        if params[:mailer]
            @notification.mailer = params[:mailer]
            @notification.email
        end
      end
    end
    
    if @notification.update(sent_at: DateTime.now)
      @notification
    else
      nil
    end
  end
  
  def notification
  end
end