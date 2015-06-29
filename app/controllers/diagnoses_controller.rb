class DiagnosesController < ApplicationController
  protect_from_forgery
  skip_before_action :verify_authenticity_token, if: :json_request?
  after_filter do
    puts @error_msg
  end

  before_action :set_diagnosis, only: [:show, :edit, :update, :destroy]

  # GET /diagnoses
  # GET /diagnoses.json
  def index
    @diagnoses = Diagnosis.all
  end

  # GET /diagnoses/1
  # GET /diagnoses/1.json
  def show
  end

  # GET /diagnoses/new
  def new
    @diagnosis = Diagnosis.new
  end

  # GET /diagnoses/1/edit
  def edit
  end

  # JSON only
  # POST /diagnoses.json
  def create
    @diagnosis = Diagnosis.new(diagnosis_params)
    @equipment = new_equipment(params[:equipment], params[:data].to_json)
    if @equipment
      @equipment.diagnosis = @diagnosis 
    else
      @diagnosis.errors[:equipment] << "is not generated."
    end

    respond_to do |format|
      if @equipment and @diagnosis.save 
        if @equipment.save 
          format.html { redirect_to @equipment, notice: 'Diagnosis was successfully created.' }
          format.json { render :show, status: :created, location: @diagnosis }
        else
          @diagnosis.delete
          format.html { render :new }
          format.json { render json: {:equipment => @equipment.errors, :diagnosis => @diagnosis.errors}, status: :unprocessable_entity }          
        end
      else
        format.html { render :new }
        format.json { render json: @diagnosis.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /diagnoses/1
  # PATCH/PUT /diagnoses/1.json
  def update
    respond_to do |format|
      if @diagnosis.update(diagnosis_params)
        format.html { redirect_to @diagnosis, notice: 'Diagnosis was successfully updated.' }
        format.json { render :show, status: :ok, location: @diagnosis }
      else
        format.html { render :edit }
        format.json { render json: @diagnosis.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /diagnoses/1
  # DELETE /diagnoses/1.json
  def destroy
    @diagnosis.destroy
    respond_to do |format|
      format.html { redirect_to diagnoses_url, notice: 'Diagnosis was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_diagnosis
      @diagnosis = Diagnosis.find(params[:id])
    end
    
    def measured_time
      DateTime.new(* Diagnosis::DATETIME_FIELDS.map { |field| params[field] })
    rescue
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def diagnosis_params
      if params[:diagnosis]
        params[:diagnosis][:measured_at] = measured_time 
        params.require(:diagnosis).permit(:protocol, :version, :equipment, :measured_at, :elapsed_time, :ip_address, :latitude, :longitude, :sex, :age_band, :order_number)
      end
    end
    
    def new_equipment(name, data)
      equipment = Equipment.find_by equipment: name
      if equipment
        @equipment = Object.const_get(equipment[:klass]).new
        @equipment.from_json data if data
        @equipment
      end
    end
    
    def json_request?
      request.format.json?
    end 
end
