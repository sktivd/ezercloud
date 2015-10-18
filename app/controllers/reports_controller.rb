class ReportsController < ApplicationController
  protect_from_forgery
#  skip_before_action :verify_authenticity_token, if: :json_request?
  skip_before_action :verify_authenticity_token, if: :from_local?
  skip_before_action :authorize, only: [:create]

  before_action :set_report, only: [:show, :edit, :update, :destroy]

  # GET /reports
  # GET /reports.json
  def index
    @reports = Report.all
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
    @report.reagent = Reagent.find_by(number: @report.reagent_number) if @report.reagent_number
  
    respond_to do |format|
      if @report.save
        
        # remove old duplicated report
        if (@old_report = Report.find_by(equipment: @report.equipment, serial_number: @report.serial_number, date: @report.date, reagent: @report.reagent)) and @old_report.id != @report.id
          destroyed = " This report replaces report #{@old_report.id}: #{@old_report.document_file_name}." 
          @old_report.destroy
        else
          destroyed = ''
        end
        
        # send to ezercloud.com - sidekiq later
        report_uri = URI.parse(Report::REPORT_URI)
        report_request = Net::HTTP::Post::Multipart.new report_uri.path, "file" => UploadIO.new(File.open(@report.document.path), 'application/pdf', [@report.date.to_s, @report.equipment, @report.serial_number, @report.reagent.number.to_s].join('_') + ".pdf")
        report_response = Net::HTTP.start(report_uri.host, report_uri.port, use_ssl: report_uri.scheme == 'https', verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
          http.request(report_request)
        end
        @report.update({ transmitted_at: DateTime.now }) if report_response.kind_of? Net::HTTPSuccess
        
        format.html { redirect_to reports_path, notice: 'Report was successfully created.' + destroyed }
        format.json { render :show, status: :created, location: @report }
      else
        format.html { render :new }
        format.json { render json: @report.errors, status: :unprocessable_entity }
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
      params.require(:report).permit(:equipment, :serial_number, :date, :document, :reagent_id, :reagent_number)
    end
    
    def json_request?
      request.format.json?
    end
    
    def from_local?
      request.remote_ip == "127.0.0.1"
    end
end
