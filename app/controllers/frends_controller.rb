class FrendsController < ApplicationController
  before_action :set_frend, only: [:show, :edit, :update, :destroy]

  # GET /frends
  # GET /frends.json
  def index
    @frends = Frend.all
  end

  # GET /frends/1
  # GET /frends/1.json
  def show
  end

  # GET /frends/new
  def new
    @frend = Frend.new
  end

  # GET /frends/1/edit
  def edit
  end

  # POST /frends
  # POST /frends.json
  def create
    @frend = Frend.new(frend_params)

    respond_to do |format|
      if @frend.save
        format.html { redirect_to @frend, notice: 'Frend was successfully created.' }
        format.json { render :show, status: :created, location: @frend }
      else
        format.html { render :new }
        format.json { render json: @frend.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /frends/1
  # PATCH/PUT /frends/1.json
  def update
    respond_to do |format|
      if @frend.update(frend_params)
        format.html { redirect_to @frend, notice: 'Frend was successfully updated.' }
        format.json { render :show, status: :ok, location: @frend }
      else
        format.html { render :edit }
        format.json { render json: @frend.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /frends/1
  # DELETE /frends/1.json
  def destroy
    @frend.destroy
    respond_to do |format|
      format.html { redirect_to frends_url, notice: 'Frend was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_frend
      @frend = Frend.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def frend_params
      params.require(:frend).permit(:version, :manufacturer, :serial_number, :test_type, :processed, :error_code, :device_id, :device_ln, :test0_id, :test1_id, :test2_id, :test0_result, :test1_result, :test2_result, :test0_integral, :test1_integral, :test2_integral, :control_integral, :double, :test0_center_point, :test1_center_point, :test2_center_point, :control_center_point, :average_background, :measured_points, :point_intensities, :external_qc_service_id, :external_qc_catalog, :external_qc_ln, :external_qc_level, :internal_qc_laser_power_test, :internal_qc_laseralignment_test, :internal_qc_calcaulated_ratio_test, :internal_qc_test)
    end
end
