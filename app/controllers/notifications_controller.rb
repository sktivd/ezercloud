class NotificationsController < ApplicationController 
  before_action :set_notification, only: [:show, :edit, :update, :destroy, :notify]

  # GET /notifications
  # GET /notifications.json
  def index
    @page = params[:page] || '1'
    if policy(Notification).manage?
      @manager = true
      if params[:see_all]
        @notifications = Notification.order(:created_at).reverse_order.page(@page).per(10)
        @see_all = true
      else
        @notifications = Notification.where(account_id: current_account.id).order(:created_at).reverse_order.page(@page).per(10)
      end        
    else
      @notifications = Notification.where(account_id: current_account.id).order(:created_at).reverse_order.page(@page).per(10)
    end
  end

  # GET /notifications/1
  # GET /notifications/1.json
  def show
  end

  # GET /notifications/new
  def new
    @notification = Notification.new
  end

  # GET /notifications/1/edit
  def edit
  end

  # POST /notifications
  # POST /notifications.json
  def create
    @notification = Notification.new(notification_params)

    respond_to do |format|
      if @notification.save
        format.html { redirect_to @notification, notice: 'Notification was successfully created.' }
        format.json { render :show, status: :created, location: @notification }
      else
        format.html { render :new }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notifications/1
  # PATCH/PUT /notifications/1.json
  def update
    respond_to do |format|
      if @notification.update(notification_params)
        format.html { redirect_to @notification, notice: 'Notification was successfully updated.' }
        format.json { render :show, status: :ok, location: @notification }
      else
        format.html { render :edit }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.json
  def destroy
    @notification.destroy
    respond_to do |format|
      format.html { redirect_to notifications_url, notice: 'Notification was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def notify
    @notification.update(notified_at: DateTime.now)  
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notification
      @notification = Notification.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def notification_params
      params.require(:notification).permit(:follow, :authentication_key, :tag, :every, :sent_at, :notified_at, :reaction_type, :content)
    end
end
