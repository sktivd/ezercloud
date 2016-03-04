class BuddisController < ApplicationController
  before_action :set_buddi, only: [:show, :edit, :update, :destroy]

  # GET /buddis
  # GET /buddis.json
  def index
    @buddis = Buddi.all
  end

  # GET /buddis/1
  # GET /buddis/1.json
  def show
  end

  # GET /buddis/new
  def new
    @buddi = Buddi.new
  end

  # GET /buddis/1/edit
  def edit
  end

  # POST /buddis
  # POST /buddis.json
  def create
    @buddi = Buddi.new(buddi_params)

    respond_to do |format|
      if @buddi.save
        format.html { redirect_to @buddi, notice: 'Buddi was successfully created.' }
        format.json { render :show, status: :created, location: @buddi }
      else
        format.html { render :new }
        format.json { render json: @buddi.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /buddis/1
  # PATCH/PUT /buddis/1.json
  def update
    respond_to do |format|
      if @buddi.update(buddi_params)
        format.html { redirect_to @buddi, notice: 'Buddi was successfully updated.' }
        format.json { render :show, status: :ok, location: @buddi }
      else
        format.html { render :edit }
        format.json { render json: @buddi.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /buddis/1
  # DELETE /buddis/1.json
  def destroy
    @buddi.destroy
    respond_to do |format|
      format.html { redirect_to buddis_url, notice: 'Buddi was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_buddi
      @buddi = Buddi.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def buddi_params
      params.require(:buddi).permit(:version, :manufacturer, :serial_number, :processed, :error_code, :kit, :lot, :device_expired_date, :patient_id, :test_zone_data, :control_zone_data, :ratio_data)
    end
end
