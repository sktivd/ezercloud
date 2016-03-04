class EzerReadersController < ApplicationController
  before_action :set_ezer_reader, only: [:show, :edit, :update, :destroy]

  # GET /ezer_readers
  # GET /ezer_readers.json
  def index
    @ezer_readers = EzerReader.all
  end

  # GET /ezer_readers/1
  # GET /ezer_readers/1.json
  def show
  end

  # GET /ezer_readers/new
  def new
    @ezer_reader = EzerReader.new
  end

  # GET /ezer_readers/1/edit
  def edit
  end

  # POST /ezer_readers
  # POST /ezer_readers.json
  def create
    @ezer_reader = EzerReader.new(ezer_reader_params)

    respond_to do |format|
      if @ezer_reader.save
        format.html { redirect_to @ezer_reader, notice: 'Ezer reader was successfully created.' }
        format.json { render :show, status: :created, location: @ezer_reader }
      else
        format.html { render :new }
        format.json { render json: @ezer_reader.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ezer_readers/1
  # PATCH/PUT /ezer_readers/1.json
  def update
    respond_to do |format|
      if @ezer_reader.update(ezer_reader_params)
        format.html { redirect_to @ezer_reader, notice: 'Ezer reader was successfully updated.' }
        format.json { render :show, status: :ok, location: @ezer_reader }
      else
        format.html { render :edit }
        format.json { render json: @ezer_reader.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ezer_readers/1
  # DELETE /ezer_readers/1.json
  def destroy
    @ezer_reader.destroy
    respond_to do |format|
      format.html { redirect_to ezer_readers_url, notice: 'Ezer reader was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ezer_reader
      @ezer_reader = EzerReader.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ezer_reader_params
      params.require(:ezer_reader).permit(:version, :manufacturer, :serial_number, :processed, :error_code, :kit_maker, :kit, :lot, :test_decision, :user_comment, :test_id, :test_result, :test_threshold, :patient_id, :weather, :temperature, :humidity)
    end
end
