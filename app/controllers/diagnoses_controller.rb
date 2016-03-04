class DiagnosesController < ApplicationController
  protect_from_forgery
  skip_before_action :verify_authenticity_token, if: :json_request?
  skip_before_action :authorize, only: [:create]
  before_action only: [:new, :update, :edit, :destroy] do
    allow_only_to :super
  end

  before_action :set_diagnosis, only: [:show, :edit, :update, :destroy]

  # GET /diagnoses
  # GET /diagnoses.json
  def index
    respond_to do |format|
      format.html do
        @active = params[:active] || 'diagnoses'
        @page = params[:page] || '1'
        
        @diagnoses = Diagnosis.read.page(@page).per(20)
        @equipment_list = {}
        @assay_kit_list = {}
        @reagent_list   = {}
        authorized_equipment.each do |equipment|
          @equipment_list[equipment.db] = Object.const_get(equipment.klass).read.page(@page).per(20)
          @assay_kit_list[equipment.db] = AssayKit.equipment equipment.equipment, @equipment_list[equipment.db].map { |equipment| equipment.kit }.uniq
        end
      end
      format.js do
        @active = params[:active] || 'diagnoses'
        @page = params[:page] || '1'
        
        if @active == 'diagnoses'
          @equipment_value = Diagnosis.read.page(@page).per(20)
        else
          active_equipment = Equipment.find_by(db: @active)
          @equipment_value = Object.const_get(active_equipment.klass).read.page(@page).per(20)
          @assay_kits = AssayKit.equipment active_equipment.equipment, @equipment_value.map { |equipment| equipment.kit }.uniq
        end
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

  # GET /diagnoses/1
  # GET /diagnoses/1.json
  def show
  end

  # GET /diagnoses/new
  def new
    @diagnosis = Diagnosis.new
  end

#  # GET /diagnoses/1/edit
#  def edit
#  end

  # JSON only
  # POST /diagnoses.json
  def create
    @diagnosis = Diagnosis.new(diagnosis_params)
    @equipment = new_equipment(params[:equipment], params[:data].to_json)
    if @equipment
      @equipment.diagnosis = @diagnosis 
    else
      @diagnosis.errors.add(:data_for_equipment, "is not generated.")
    end

    respond_to do |format|
      if @equipment and @diagnosis.save 
        if @equipment.save
          @equipment.notification
          
          format.html { redirect_to @equipment, notice: 'Diagnosis was successfully created.' }
          format.json { render :created, status: :created, location: @diagnosis }
        else
          @diagnosis.delete
          @diagnosis.errors.add(:response, "fail")
          @diagnosis.errors.add(:data, @equipment.errors)
          format.html { render :new }
          format.json { render json: @diagnosis.errors, status: :unprocessable_entity }          
        end
      else
        @diagnosis.errors.add(:response, "fail")
        format.html { render :new }
        format.json { render json: @diagnosis.errors, status: :unprocessable_entity }
      end
    end
  end

#  # PATCH/PUT /diagnoses/1
#  # PATCH/PUT /diagnoses/1.json
#  def update
#    respond_to do |format|
#      if @diagnosis.update(diagnosis_params)
#        format.html { redirect_to @diagnosis, notice: 'Diagnosis was successfully updated.' }
#        format.json { render :show, status: :ok, location: @diagnosis }
#      else
#        format.html { render :edit }
#        format.json { render json: @diagnosis.errors, status: :unprocessable_entity }
#      end
#    end
#  end

  # DELETE /diagnoses/1
  # DELETE /diagnoses/1.json
  def destroy
    @page = params[:page] || "1"
    
    equipment_name = all_equipment.find { |equipment| equipment.klass == @diagnosis.diagnosable_type }.equipment
    Object.const_get(@diagnosis.diagnosable_type).find(@diagnosis.diagnosable_id).delete
    @diagnosis.delete
    respond_to do |format|
      format.html { redirect_to diagnoses_url(page: @page), notice: "Diagnosis (#{equipment_name}) was successfully removed." }
      format.js do
        @active = params[:active] || "diagnoses"
        @notice = "Diagnosis (#{equipment_name}) was successfully removed."
        if @active == 'diagnoses'
          @equipment_value = Diagnosis.read.page(@page).per(20)
        else
          @diagnoses = Diagnosis.read.page(@page).per(20)
          active_equipment = Equipment.find_by(db: @active)
          @equipment_value = Object.const_get(active_equipment.klass).read.page(@page).per(20)
          @assay_kits = AssayKit.equipment active_equipment.equipment, @equipment_value.map { |equipment| equipment.kit }.uniq
        end
      end
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_diagnosis
      @diagnosis = Diagnosis.find(params[:id])
    end
    
    def measured_time
      DateTime.new(* Diagnosis::DATETIME_FIELDS.map { |field| params[field].to_i }, params[Diagnosis::TIMEZONE_FIELD])
    rescue
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def diagnosis_params
      if params[:diagnosis]
        params[:diagnosis][:measured_at] = measured_time
        params[:diagnosis][:authentication_key] = params[:authentication_key]
        params[:diagnosis][:remote_ip] = request.remote_ip.to_sym

        params.require(:diagnosis).permit(:authentication_key, :remote_ip, :protocol, :version, :equipment, :measured_at, :elapsed_time, :ip_address, :location, :latitude, :longitude, :sex, :age_band, :order_number, :technician)
      end
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
