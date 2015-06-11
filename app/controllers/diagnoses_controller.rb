class DiagnosesController < ApplicationController
  protect_from_forgery
  skip_before_action :verify_authenticity_token, if: :json_request?

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

  # POST /diagnoses
  # POST /diagnoses.json
  def create
    @diagnosis = Diagnosis.new(diagnosis_params)
    if @diagnosis[:measured_at].nil?
      @diagnosis.errors[:measured_at] << "invalid datetime"
    elsif @diagnosis[:measured_at].year < Diagnosis::MIN_YEAR or @diagnosis[:measured_at].year  > Diagnosis::MAX_YEAR
      @diagnosis.errors[:year] << "is out of allowed period [" + Diagnosis::MIN_YEAR.to_s + ", " + Diagnosis::MAX_YEAR.to_s + "]"
      @diagnosis[:measured_at] = nil
    end

    respond_to do |format|
      if @diagnosis[:measured_at] and @diagnosis.save
        format.html { redirect_to @diagnosis, notice: 'Diagnosis was successfully created.' }
        format.json { render :show, status: :created, location: @diagnosis }
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
      nil
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def diagnosis_params
      params[:diagnosis][:measured_at] = measured_time
      params.require(:diagnosis).permit(:protocol, :version, :authorized_key, :equipment, :measured_at, :elapsed_time, :ip_address, :latitude, :longitude, :data)
    end
    
    def json_request?
      request.format.json?
    end 
end
