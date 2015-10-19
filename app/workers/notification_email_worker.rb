class NotificationEmailWorker
  include Sidekiq::Worker
  sidekiq_options queue: :high_priority
  sidekiq_options retry:5
  
  RECHECK_TIME = 1
  
  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end
  
  # The current retry count is yielded. The return value of the block must be 
  # an integer. It is used as the delay, in seconds. 
  sidekiq_retry_in do |count|
    10 * (count + 1) # (i.e. 10, 20, 30, 40)
  end
  
  def perform options
    options       = JSON.parse options.to_json, symbolize_names: true
    @notification = Notification.find(options[:id])
    
    if @notification and @notification.notified_at.nil?
      Notifier.send(@notification.mailer.to_sym, @notification).deliver_now
      @notification.update(sent_at: DateTime.now)
      NotificationEmailWorker.perform_at(RECHECK_TIME.days.from_now, id: @notification.id)
    end
  end
  
end