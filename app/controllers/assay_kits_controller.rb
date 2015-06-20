class AssayKitsController < ApplicationController
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
    @assay_kit.reagents.build
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
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def assay_kit_params
      params.require(:assay_kit).permit(:equipment, :manufacturer, :kit_id)
    end
end
