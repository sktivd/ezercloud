module AvailableEquipment
  extend ActiveSupport::Concern
  
  private
  
  def set_qcm_menu
    @equipment    = Equipment.order(:equipment)
    if session[:qcm_equipment]
      @assay_kits = AssayKit.where(equipment: session[:qcm_equipment]).order(:device)
    else
      @assay_kits = nil
    end
    if session[:qcm_assay_kit]
      @reagents   = Reagent.where(assay_kit_id: session[:qcm_assay_kit]).order(:name) 
    else
      @reagents   = nil
    end
  end
end