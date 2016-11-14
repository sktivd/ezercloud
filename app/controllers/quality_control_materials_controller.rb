class QualityControlMaterialsController < ApplicationController
  before_action do
    authorize QualityControlMaterial, :manage?
  end
  before_action :set_quality_control_material, only: [:edit, :update, :destroy]

  # GET /quality_control_materials
  # GET /quality_control_materials.json
  def index
    @quality_control_materials = QualityControlMaterial.order(:expire).reverse_order
  end

#  # GET /quality_control_materials/1
#  # GET /quality_control_materials/1.json
#  def show
#  end

  # GET /quality_control_materials/new
  def new
    @quality_control_material = QualityControlMaterial.new
    if params[:quality_control_material]
      @quality_control_material.assign_attributes(quality_control_material_params)
    end
    
    session[:qcm_equipment] = @quality_control_material.equipment if @quality_control_material.equipment
    session[:qcm_assay_kit] = @quality_control_material.assay_kit if @quality_control_material.assay_kit
    session[:qcm_plate]     = @quality_control_material.plate_id  if @quality_control_material.plate_id
  end

  # GET /quality_control_materials/1/edit
  def edit
  end

  # POST /quality_control_materials
  # POST /quality_control_materials.json
  def create
    @quality_control_material = QualityControlMaterial.new(quality_control_material_params)
    assign_remained_attributes
        
    respond_to do |format|
      if  @quality_control_material.save
        format.html { redirect_to quality_control_materials_url, notice: 'New QC material was successfully created.' }
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
    @quality_control_material.assign_attributes(quality_control_material_params)
    assign_remained_attributes
    
    respond_to do |format|
      if @quality_control_material.save
        format.html { redirect_to quality_control_materials_url, notice: 'The QC material was successfully updated.' }
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
      format.html { redirect_to quality_control_materials_url, notice: 'The QC material was successfully removed.' }
      format.json { head :no_content }
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quality_control_material
      @quality_control_material = QualityControlMaterial.find(params[:id])
      @quality_control_material.assay_kit = @quality_control_material.plate.assay_kit_id
      @quality_control_material.lower_3sd = @quality_control_material.mean - 3 * @quality_control_material.sd
      @quality_control_material.upper_3sd = @quality_control_material.mean + 3 * @quality_control_material.sd
      
      session[:qcm_equipment] = @quality_control_material.equipment
      session[:qcm_assay_kit] = @quality_control_material.assay_kit
      session[:qcm_plate]     = @quality_control_material.plate_id
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quality_control_material_params
      params.require(:quality_control_material).permit(:service, :lot, :expire, :equipment, :mean, :sd, :lower_3sd, :upper_3sd, :plate_id)
    end
    
    def assign_remained_attributes
      if @quality_control_material.lower_3sd.nil? and @quality_control_material.mean
        @quality_control_material.lower_3sd = @quality_control_material.mean - 3 * @quality_control_material.sd
        @quality_control_material.upper_3sd = @quality_control_material.mean + 3 * @quality_control_material.sd
      else
        @quality_control_material.mean = (@quality_control_material.lower_3sd.to_f + @quality_control_material.upper_3sd.to_f) / 2
        @quality_control_material.sd = (@quality_control_material.upper_3sd.to_f - @quality_control_material.mean) / 3
      end
    
      @quality_control_material.equipment = session[:qcm_equipment]
      @quality_control_material.plate     = Plate.find(session[:qcm_plate]) if session[:qcm_plate]
    end

end
