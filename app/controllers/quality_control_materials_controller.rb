class QualityControlMaterialsController < ApplicationController
  before_action :set_quality_control_material, only: [:show, :edit, :update, :destroy]

  # GET /quality_control_materials
  # GET /quality_control_materials.json
  def index
    @quality_control_materials = QualityControlMaterial.all
  end

  # GET /quality_control_materials/1
  # GET /quality_control_materials/1.json
  def show
  end

  # GET /quality_control_materials/new
  def new
    @quality_control_material = QualityControlMaterial.new
  end

  # GET /quality_control_materials/1/edit
  def edit
  end

  # POST /quality_control_materials
  # POST /quality_control_materials.json
  def create
    @quality_control_material = QualityControlMaterial.new(quality_control_material_params)

    respond_to do |format|
      if @quality_control_material.save
        format.html { redirect_to @quality_control_material, notice: 'Quality control material was successfully created.' }
        format.json { render :show, status: :created, location: @quality_control_material }
      else
        format.html { render :new }
        format.json { render json: @quality_control_material.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /quality_control_materials/1
  # PATCH/PUT /quality_control_materials/1.json
  def update
    respond_to do |format|
      if @quality_control_material.update(quality_control_material_params)
        format.html { redirect_to @quality_control_material, notice: 'Quality control material was successfully updated.' }
        format.json { render :show, status: :ok, location: @quality_control_material }
      else
        format.html { render :edit }
        format.json { render json: @quality_control_material.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quality_control_materials/1
  # DELETE /quality_control_materials/1.json
  def destroy
    @quality_control_material.destroy
    respond_to do |format|
      format.html { redirect_to quality_control_materials_url, notice: 'Quality control material was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quality_control_material
      @quality_control_material = QualityControlMaterial.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quality_control_material_params
      params.require(:quality_control_material).permit(:service, :lot, :expire, :equipment, :reagent_name, :reagent_number, :mean, :sd, :reagent_id)
    end
end
