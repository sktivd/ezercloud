class ResponsesController < ApplicationController
  skip_before_action :authenticate_account!
  before_action :set_notification, only: [:contact]
    
  def contact
    the_path = Rails.application.routes.recognize_path params[:redirect_path]
    if @notification.notified_at.nil?
      now = DateTime.now
      Notification.where(tag: @notification.tag).each { |notified| notified.update(notified_at: now) }
      redirect_to the_path.merge(params.except(:redirect_path, :controller, :action, :id)), notice: "Generated by Notification"
    else
      redirect_to the_path.merge(params.except(:redirect_path, :controller, :action, :id)), notice: "Already notified item"
    end
  rescue
    @notification.update(expired_at: DateTime.now) if @notification
    logger.info "Invalid notification response: invalid connection"
    redirect_to root_path, notice: "Invalid notification response"
  end
  
  private
  
    def set_notification
      @notification = Notification.find(params[:id])
      if @notification.account != current_account
        redirect_to root_path, notice: "Different with notified account..."
      end
      if @notification.authentication_key == (params[:authentication_key]) && @notification.redirect_path == params[:redirect_path]
        if @notification.expired_at < DateTime.now
          redirect_to root_path, notice: "Notification has been already expired!"
        end
        @notification
      else
        logger.info "Invalid notification response: wrong authentication code"
        redirect_to root_path, notice: "Invalid notification response"
      end
    rescue ActiveRecord::RecordNotFound
      logger.info "Invalid notification response: nonexistance notification"
      redirect_to root_path, notice: "Invalid notification response"      
    end
    
end
