class AkDropdownController < ApplicationController
  include AvailableEquipment
  before_action only: [:create] do
    allow_only_to :reagent
  end
  before_action :set_ak, only: [:create]
  
  def create
    parameters = ak_params
    if parameters[:type] == 'equipment'
      @assay_kit.equipment    = parameters[:value]
      @assay_kit.reagent_list = []
      session[:ak_equipment]  = @assay_kit.equipment
    end
    session[:ak_reagent] = @assay_kit.reagent_list
    @reagents            = Reagent.where(equipment: @assay_kit.equipment)
    
    respond_to do |format|
      format.js
    end
  end
  
  private
    
    def set_ak
      @assay_kit = AssayKit.new
      @assay_kit.equipment    = session[:ak_equipment]
    end
    
    def ak_params
      params.require(:ak).permit(:type, :value)
    end
end
