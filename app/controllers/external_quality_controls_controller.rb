class ExternalQualityControlsController < ApplicationController
  before_action :set_external_quality_control, only: [:show, :edit, :update, :destroy]

  # GET /external_quality_controls
  # GET /external_quality_controls.json
  def index
    @external_quality_controls = ExternalQualityControl.all
  end

  # GET /external_quality_controls/1
  # GET /external_quality_controls/1.json
  def show
  end

  # GET /external_quality_controls/new
  def new
    @external_quality_control = ExternalQualityControl.new
  end

  # GET /external_quality_controls/1/edit
  def edit
  end

  # POST /external_quality_controls
  # POST /external_quality_controls.json
  def create
    @external_quality_control = ExternalQualityControl.new(external_quality_control_params)

    respond_to do |format|
      if @external_quality_control.save
        format.html { redirect_to @external_quality_control, notice: 'External quality control was successfully created.' }
        format.json { render :show, status: :created, location: @external_quality_control }
      else
        format.html { render :new }
        format.json { render json: @external_quality_control.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /external_quality_controls/1
  # PATCH/PUT /external_quality_controls/1.json
  def update
    respond_to do |format|
      if @external_quality_control.update(external_quality_control_params)
        format.html { redirect_to @external_quality_control, notice: 'External quality control was successfully updated.' }
        format.json { render :show, status: :ok, location: @external_quality_control }
      else
        format.html { render :edit }
        format.json { render json: @external_quality_control.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /external_quality_controls/1
  # DELETE /external_quality_controls/1.json
  def destroy
    @external_quality_control.destroy
    respond_to do |format|
      format.html { redirect_to external_quality_controls_url, notice: 'External quality control was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_external_quality_control
      @external_quality_control = ExternalQualityControl.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def external_quality_control_params
      params.require(:external_quality_control).permit(:equipment, :device_id, :test_id, :sample_type, :reagent, :lot_number, :expired_at, :unit, :mean, :sd)
    end
end
