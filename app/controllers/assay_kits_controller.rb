class AssayKitsController < ApplicationController
  before_action only: [:new, :create, :update, :edit, :destroy] do
    allow_only_to :reagent
  end
  before_action :set_assay_kit, only: [:show, :edit, :update, :destroy]

  # GET /assay_kits
  # GET /assay_kits.json
  def index
    @assay_kits = AssayKit.where(equipment: authorized_equipment.map{ |e| e.equipment }).includes(:reagents)
  end

  # GET /assay_kits/1
  # GET /assay_kits/1.json
  def show
  end

  # GET /assay_kits/new
  def new
    @assay_kit = AssayKit.new
    @assay_kit.reagent_list = []
    
    @reagents = nil
  end

  # GET /assay_kits/1/edit
  def edit
    @reagents = Reagent.where(equipment: @assay_kit.equipment) if @assay_kit.equipment
  end

  # POST /assay_kits
  # POST /assay_kits.json
  def create
    @assay_kit = AssayKit.new(assay_kit_params)

    respond_to do |format|
      begin
        ActiveRecord::Base.transaction do
          @assay_kit.save!
          @reagent_list.each { |reagent_id| @assay_kit.plates.create! reagent_id: reagent_id }
        end
        format.html { redirect_to assay_kits_path, notice: 'Assay kit was successfully created.' }
        format.json { render :show, status: :created, location: @assay_kit }
      rescue ActiveRecord::ActiveRecordError => e
        format.html { render :new }
        format.json { render json: e.message, status: :unprocessable_entity }
      end      
    end
  end

  # PATCH/PUT /assay_kits/1
  # PATCH/PUT /assay_kits/1.json
  def update
    respond_to do |format|
      begin
        ActiveRecord::Base.transaction do
          @assay_kit.update!(assay_kit_params)
          @assay_kit.plates.where.not(reagent_id: @reagent_list).destroy_all
          @reagent_list.each { |reagent_id| @assay_kit.plates.create! reagent_id: reagent_id }
        end
        format.html { redirect_to assay_kits_path, notice: 'Assay kit was successfully updated.' }
        format.json { render :show, status: :ok, location: @assay_kit }
      rescue ActiveRecord::ActiveRecordError => e
        format.html { render :edit }
        format.json { render json: e.message, status: :unprocessable_entity }
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
      @assay_kit.reagent_list = @assay_kit.plates.map{ |plate| plate.reagent_id }
      
      session[:ak_equipment] = @assay_kit.equipment
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def assay_kit_params
      reagent_param = params.require(:assay_kit).permit(reagent_list: [])
      @reagent_list = reagent_param[:reagent_list].compact
      STDERR.puts reagent_param
      STDERR.puts "reagent list: " + @reagent_list.to_s
      params.require(:assay_kit).permit(:equipment, :manufacturer, :device, :kit, :diagnosis_ruleset)
    end
end
