class QcmDropdownController < ApplicationController  
  include AvailableEquipment
  before_action only: [:create] do
    allow_only_to :reagent
  end
  before_action :set_qcm, only: [:create]
  before_action :set_qcm_menu, only: [:create]

  def create
    parameters = qcm_params
    if parameters[:type]
      if parameters[:type] == 'equipment'
        @qcm.equipment = parameters[:value]
        @qcm.assay_kit = nil
        @qcm.reagent   = nil
        session[:qcm_equipment] = parameters[:value]
        session[:qcm_assay_kit] = nil
        session[:qcm_reagent]   = nil
        @assay_kits = AssayKit.where(equipment: session[:qcm_equipment]).order(:device)
        @reagents = nil
      elsif parameters[:type] == 'assay_kit'
        @qcm.assay_kit = parameters[:value]
        @qcm.reagent   = nil
        session[:qcm_assay_kit] = parameters[:value]
        session[:qcm_reagent]   = nil
        @reagents   = Reagent.where(assay_kit_id: session[:qcm_assay_kit]).order(:name) 
      elsif parameters[:type] == 'reagent'
        @qcm.reagent = Reagent.find(parameters[:value])
        session[:qcm_reagent] = parameters[:value]
      end
    end
        
    respond_to do |format|
      format.js
    end
  end
  
  private
  
  def set_qcm
    @qcm = QualityControlMaterial.new
    @qcm.equipment    = session[:qcm_equipment] if session[:qcm_equipment]
    if session[:qcm_reagent]
      @qcm.reagent    = Reagent.find(session[:qcm_reagent]) 
      @qcm.assay_kit  = AssayKit.find(@qcm.reagent.assay_kit_id)
    elsif session[:qcm_assay_kit]
      @qcm.assay_kit  = session[:qcm_assay_kit]
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def qcm_params
    params.require(:qcm).permit(:type, :value)
  end  
end
