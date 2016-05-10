class AssayKit < ActiveRecord::Base
  has_many :reagents, dependent: :destroy
  accepts_nested_attributes_for :reagents, reject_if: lambda { |e| e[:name].blank? or e[:number].to_i <= 0 }, allow_destroy: true
  
  def self.equipment equipment, equipment_kits
    assay_kits = {}
    # set unknown kit as default
    equipment_kits.each{ |kit| assay_kits[kit] = { kit: kit, reagents: ["unknown kit"]} }
    AssayKit.includes(:reagents).where(equipment: equipment, kit: equipment_kits).each do |assay_kit|
      assay_kits[assay_kit.kit] = { kit: assay_kit.device, reagents: assay_kit.reagents.map { |reagent| reagent.name } }
    end
    assay_kits
  end
  
end
