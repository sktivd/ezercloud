module NotificationMethods
  extend ActiveSupport::Concern
  
  private
  
    AVAILABLE_NOTIFICATION_TYPES = [:response, :account_validation]
  
    def _send_email_notification params
      # parameters
      notification_params = params.select { |key, value| [:follow, :tag, :message, :redirect_path, :user, :mailer, :every, :expired_at, :data].include?(key) }
      notification_params[:follow]  = Notification::TYPES[notification_params[:follow]]
      notification_params[:every]   = notification_params[:every].to_i if notification_params[:every]
      notification_params[:user_id] = notification_params[:user].id
      notification_params[:data]    = notification_params[:data].to_json if notification_params[:data]

      @notification = Notification.new notification_params
      @notification.authentication_key = Digest::SHA256.hexdigest @notification.to_s
  
      if @notification.save
        @notification.set_url(params[:parameters])
        @notification.save
        case @notification.follow
        when *AVAILABLE_NOTIFICATION_TYPES.map { |type| Notification::TYPES[type] }
          @notification.email if @notification.mailer
        end
        @notification
      end
    end
  
    def send_email_notification notifications, options = {}
      if notifications
        if notifications.class == Array
          notifications.each do |params|
            Notification.find_by(tag: params[:tag]).delete if options[:replacement]
            _send_email_notification params
          end
        else
          Notification.find_by(tag: notifications[:tag]).delete if options[:replacement]
          _send_email_notification notifications
        end
      end
    end
      
end
