class ReagentsController < ApplicationController
  before_action only: [:new, :create, :update, :edit, :destroy] do
    allow_only_to :reagent
  end
  before_action :set_reagent, only: [:show, :edit, :update, :destroy]
  
  # GET /reagents
  # GET /reagents.json
  def index
    @reagents = Reagent.order([:equipment, :number]).all
  end
  
  # GET /reagents/new
  def new
    @reagent = Reagent.new
  end
  
  # GET /reagents/1/edit
  def edit
  end
  
  # POST /assay_kits
  # POST /assay_kits.json
  def create
    @reagent = Reagent.new(reagent_params)

    respond_to do |format|
      if @reagent.save
        format.html { redirect_to reagents_url, notice: 'Reagent was successfully created.' }
        format.json { render :show, status: :created, location: @reagent }
      else
        format.html { render :new }
        format.json { render json: @reagent.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # PATCH/PUT /@reagent/1
  # PATCH/PUT /@reagent/1.json
  def update
    respond_to do |format|
      if @reagent.update(reagent_params)
        format.html { redirect_to reagents_url, notice: 'Reagent was successfully updated.' }
        format.json { render :show, status: :ok, location: @reagent }
      else
        format.html { render :edit }
        format.json { render json: @reagent.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /reagents/1
  # DELETE /reagents/1.json
  def destroy
    @reagent.destroy
    respond_to do |format|
      if @reagent.destroyed?
        format.html { redirect_to reagents_url, notice: 'Reagent was successfully removed.' }
        format.js do
          @notice = "Reagent was successfully removed."
        end
        format.json { head :no_content }
      else
        format.html { redirect_to reagents_url, notice: 'Reagent was failed to remove because of related Plates.' }
        format.js do
          @notice = "Reagent was failed to remove because of related Plates."
        end
        format.json { render json: @reagent.errors, status: :unprocessable_entity }
      end
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reagent
      @reagent = Reagent.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reagent_params
      params.require(:reagent).permit(:equipment, :name, :number, :unit, :lod, :uod, :threshold)
    end
end
