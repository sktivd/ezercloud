class AssayKitsController < ApplicationController
#  protect_from_forgery
#  skip_before_action :verify_authenticity_token
  before_action :set_assay_kit, only: [:show, :edit, :update, :destroy]

  # GET /assay_kits
  # GET /assay_kits.json
  def index
    @assay_kits = AssayKit.all
  end

  # GET /assay_kits/1
  # GET /assay_kits/1.json
  def show
  end

  # GET /assay_kits/new
  def new
    @assay_kit = AssayKit.new
  end

  # GET /assay_kits/1/edit
  def edit
  end

  # POST /assay_kits
  # POST /assay_kits.json
  def create
    @assay_kit = AssayKit.new(assay_kit_params)

    respond_to do |format|
      if @assay_kit.save
        format.html { redirect_to @assay_kit, notice: 'Assay kit was successfully created.' }
        format.json { render :show, status: :created, location: @assay_kit }
      else
        format.html { render :new }
        format.json { render json: @assay_kit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assay_kits/1
  # PATCH/PUT /assay_kits/1.json
  def update
    respond_to do |format|
      if @assay_kit.update(assay_kit_params)
        format.html { redirect_to @assay_kit, notice: 'Assay kit was successfully updated.' }
        format.json { render :show, status: :ok, location: @assay_kit }
      else
        format.html { render :edit }
        format.json { render json: @assay_kit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assay_kits/1
  # DELETE /assay_kits/1.json
  def destroy
    @assay_kit.destroy
    respond_to do |format|
      format.html { redirect_to assay_kits_url, notice: 'Assay kit was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assay_kit
      @assay_kit = AssayKit.find(params[:id])
      @assay_kit[:reagents] = [""] and @assay_kit[:references] = [0] if @assay_kit[:reagents].size == 0
    end
    
    def remove_empty_element
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def assay_kit_params
      params[:assay_kit][:reagents].each.with_index { |value, index| params[:assay_kit][:references][index] = 0 if value == "" }
      params[:assay_kit][:reagents].delete("")
      params[:assay_kit][:references].delete(0)
      params[:assay_kit][:number_of_tests] = params[:assay_kit][:reagents].size
      params.require(:assay_kit).permit(:equipment, :manufacturer, :device_id, :number_of_tests, :reagents => [], :references => [])
    end
end
