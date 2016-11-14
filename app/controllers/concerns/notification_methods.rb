module NotificationMethods
  extend ActiveSupport::Concern
  
  class NotificationError < StandardError
    attr_reader :errors
    def initialize(errors, msg = "Notification does not work correctly.")
      @errors = errors
      super
    end
  end
  
  private
    
    def _send_notification params
      @notification = Notification.new params
      if @notification.save
        @notification.send_email if @notification.mailer
        @notification
      end
    rescue ActiveRecord::RecordInvalid => e
      raise NotificationError.new(e.record.errors)
    end
  
    def send_notification notification_params, options = {}
      if notification_params
        if notification_params.class == Array
          notification_params.map do |params|
            Notification.find_by(tag: params[:tag]).delete if options[:replacement]
            _send_notification params
          end
        else
          Notification.find_by(tag: notification_params[:tag]).delete if options[:replacement]
          [_send_notification(notification_params)]
        end
      else
        raise NotificationError.new({ notifications: "No notification information" }.to_json)
      end
    end    
    
end
