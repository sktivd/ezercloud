class DiagnosesController < ApplicationController
  include NotificationMethods
  
  skip_before_action :verify_authenticity_token, if: :json_request?, only: [:create]
  skip_before_action :authenticate_account!, only: [:create]
  before_action only: [:new, :create], unless: :json_request? do
    redirect_to root_path, notice: "Artifical diagnosis creation is prohibited!"
  end
  before_action only: [:new, :update, :edit, :destroy] do
    authorize Diagnosis, :manage?
  end
  before_action :set_equipment_class, only: [:create]
  before_action only: [:index] do 
    authorize Diagnosis, :index?
  end

  before_action :set_diagnosis, only: [:show, :edit, :update, :destroy]

  # GET /diagnoses
  # GET /diagnoses.json
  def index
    respond_to do |format|
      format.html do
        @active = params[:active] || authorized_equipment.first.db
        @page = params[:page] || '1'
        
        @equipment_list = {}
        @assay_kit_list = {}
        @reagent_list   = {}
        authorized_equipment.each do |equipment|
          @equipment_list[equipment.db] = policy_scope(Object.const_get(equipment.klass)).read.page(@page).per(20)
          @assay_kit_list[equipment.db] = AssayKit.equipment equipment.equipment, @equipment_list[equipment.db].map { |equipment| equipment.kit }.uniq
        end
      end
      format.js do
        @active = params[:active] || authorized_equipment.first.db
        @page = params[:page] || '1'
        
        active_equipment = Equipment.find_by(db: @active)
        @equipment_value = policy_scope(Object.const_get(active_equipment.klass)).read.page(@page).per(20)
        @assay_kits = AssayKit.equipment active_equipment.equipment, @equipment_value.map { |equipment| equipment.kit }.uniq
      end
      format.json do
        params[:equipment] = "FREND"  if params[:equipment].nil?
        params[:from] = 1.year.ago    if params[:from].nil?
        params[:to]   = DateTime.now  if params[:to].nil?
        
        @equipment_name = Equipment.find_by(equipment: params[:equipment])
        if @equipment_name
          @equipment = Object.const_get(@equipment_name[:klass]).read.where(diagnoses: { measured_at: params[:from]..params[:to] })
        else
          redirect_to root_path, notice: 'invalid Equipment'
        end
      end
    end
  end

  def new
  end
  
  # GET /diagnoses/1
  # GET /diagnoses/1.json
  def show
    @equipment = Object.const_get(@diagnosis.diagnosable_type).find(@diagnosis.diagnosable_id)
    
    respond_to do |format|
      format.js do
        @active = params[:active] || "diagnoses"
      end
    end
  end

  # JSON only
  # POST /diagnoses.json
  def create
    Diagnosis.transaction do
      begin
        @equipment = @equipment_class.create! equipment_params          
        @diagnosis = @equipment.build_diagnosis diagnosis_params
        @diagnosis.save!

        send_notification @equipment.notification
        
        @error_type = :none
      rescue ActiveRecord::RecordInvalid
        @errors = @diagnosis.errors
        @errors.add(:response, 'fail')
        @errors.add(:data, @equipment.errors)
        @error_type = :on_create
        raise ActiveRecord::Rollback
      rescue NotificationError
        @error_type = :on_notification
      end
    end
    respond_to do |format|
      case @error_type
      when :none
        format.html { redirect_to @equipment, notice: 'Diagnosis was successfully created.' }
        format.json { render :created, status: :created, location: @diagnosis }
      when :on_create
        format.html { redirect_to :new }
        format.json { render json: @diagnosis.errors, status: :unprocessable_entity  }
      when :on_notification
        format.html { redirect_to root_path, notice: 'Diagnosis was successfully created.' + 'But, ' + e.message }
        format.json { render :created, status: :created, location: @diagnosis }
      end
    end
  end
  
  # DELETE /diagnoses/1
  # DELETE /diagnoses/1.json
  def destroy
    @page = params[:page] || "1"
    
    equipment_name = @diagnosis.measurement.equipment.equipment
    Diagnosis.transaction do
      begin
        @diagnosis.measurement.delete
        @diagnosis.delete
        respond_to do |format|
          format.html { redirect_to diagnoses_url(page: @page), notice: "A measurement (#{equipment_name}) was successfully removed." }
          format.js do
            @active = params[:active] || authorized_equipment.first.db
            @notice = "A measurement (#{equipment_name}) was successfully removed."
            active_equipment = Equipment.find_by(db: @active)
            @equipment_value = policy_scope(Object.const_get(active_equipment.klass)).read.page(@page).per(20)
            @assay_kits = AssayKit.equipment active_equipment.equipment, @equipment_value.map { |equipment| equipment.kit }.uniq
          end
          format.json { head :no_content }
        end
      rescue ActiveRecord::RecordNotDestroyed => invalid
        respond_to do |format|
          format.html { redirect_to diagnoses_url(page: @page), notice: "A measurement (#{equipment_name}) was not removed!" }
          format.json { head :no_content }
        end
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_diagnosis
      @diagnosis = Diagnosis.find(params[:id])
    end
        
    def equipment_params
      params.require(:data).permit(@equipment_class::PARAMETERS)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def diagnosis_params
      params[:remote_ip] = request.remote_ip.to_sym
      params.permit(:authentication_key, :remote_ip, :protocol, :version, :user_id, :equipment, :decision, :diagnosis_tag, :measured_at, :elapsed_time, :ip_address, :location, :latitude, :longitude, :sex, :age_band, :order_number, :technician, :person, :year, :month, :day, :hour, :minute, :second, :time_zone)
    end
    
    def set_equipment_class
      @equipment_class = Object.const_get(Equipment.find_by(equipment: params[:equipment]).klass) if params[:equipment] and params[:equipment].size > 0
      render json: { response: 'fail', equipment: 'invalid' }, status: :unprocessable_entity if @equipment_class.nil?
    end
    
    def new_equipment(name, data)
      equipment = Equipment.find_by equipment: name
      if equipment
        @equipment = Object.const_get(equipment[:klass]).new
        @equipment.from_json data if data
        @equipment
      end
    rescue ActiveRecord::UnknownAttributeError
      nil
    end
    
    def json_request?
      request.format.json?
    end     
end
