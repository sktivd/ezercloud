class ReportsController < ApplicationController
  protect_from_forgery
#  skip_before_action :verify_authenticity_token, if: :json_request?
  skip_before_action :verify_authenticity_token, if: :from_local?
  before_action except: [:create] do
    authorize Report, :manage?
  end

  before_action :set_report, only: [:show, :edit, :update, :destroy]

  # GET /reports
  # GET /reports.json
  def index
    @reports = Report.order(:created_at).reverse_order.page(params[:page]).per(20)
  end

  # GET /reports/1
  # GET /reports/1.json
  def show
  end

  # GET /reports/new
  def new
    @report = Report.new
  end

  # GET /reports/1/edit
  def edit
  end

  # POST /reports
  # POST /reports.json
  def create
    @report = Report.new(report_params)
    @report.plate = Plate.find_by(kit: @report.assay_kit, number: @report.reagent) if @report.assay_kit && @report.reagent
  
    respond_to do |format|
      if @report.plate.nil?
        @report.errors[:assay_kit] = "Wrong Kit information"
        @report.errors[:reagent] = "Wrong Reagent information"
        format.html { render :new }
        format.json { render json: { message: "Wrong Kit and Reagent information", kit: @report.assay_kit, reagent: @report.reagent }.to_json, status: :unprocessable_entity }      
      end
      
      if @report.save
        # remove old duplicated report
        if (@old_reports = Report.where(equipment: @report.equipment, serial_number: @report.serial_number, date: @report.date, plate: @report.plate).where.not(id: @report.id)).size > 0
          destroyed = " This report replaces report #{@old_reports.map { |report| report.id.to_s + ":" + report.document_file_name }.join(", ")}." 
          @old_reports.destroy_all
        else
          destroyed = ''
        end
  
        # transmit report to ezercloud.com
        ReportTransmissionWorker.perform_async(id: @report.id)
        
        format.html { redirect_to reports_path, notice: 'Report was successfully created.' + destroyed }
        format.json { render :show, status: :created, location: @report }
      else
        format.html { render :new }
        format.json { render json: e.message, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reports/1
  # PATCH/PUT /reports/1.json
  def update
    respond_to do |format|
      if @report.update(report_params)
        format.html { redirect_to @report, notice: 'Report was successfully updated.' }
        format.json { render :show, status: :ok, location: @report }
      else
        format.html { render :edit }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reports/1
  # DELETE /reports/1.json
  def destroy
    @report.destroy
    respond_to do |format|
      format.html { redirect_to reports_url, notice: 'Report was successfully removed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
      params.require(:report).permit(:equipment, :serial_number, :date, :document, :plate_id, :assay_kit, :reagent)
    end
    
    def json_request?
      request.format.json?
    end
    
    def from_local?
      request.remote_ip == "127.0.0.1"
    end
end
