class ResponsesController < ApplicationController
  before_action :set_notification, only: [:contact]
    
  def contact
    STDERR.puts params[:path]
    the_path = Rails.application.routes.recognize_path params[:path]
    method = :get
    method = params[:method].to_sym if params[:method]
    STDERR.puts params.merge(the_path)
    if @notification.notified_at.nil?
      now = DateTime.now
      Notification.where(tag: @notification.tag).each { |notified| notified.update(notified_at: now) }
      redirect_to the_path.merge(params.except(:controller, :action, :id, :method)), method: method, notice: "Generated by Notification"
    else
      redirect_to the_path.merge(params.except(:controller, :action, :id, :method)), method: method, notice: "Already notified item"
    end
  rescue
    @notification.update(expired_at: DateTime.now)
    redirect_to root_path, notice: "Wrong controller/action!"
  end
  
  private
  
    def set_notification
      if (@notification = Notification.find(params[:id])) and @notification.authentication_key == (params[:authentication_key])
        if @notification.expired_at < DateTime.now
          redirect_to root_path, notice: "Notification has been already expired!"
        end
        @notification
      else
        redirect_to root_path, notice: "Invalid notification response!"
      end
    end
    
end