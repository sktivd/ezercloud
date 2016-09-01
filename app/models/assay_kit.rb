class AssayKit < ActiveRecord::Base
  resourcify
  
  has_many :reagents, through: :plates
  has_many :plates, dependent: :destroy
#  accepts_nested_attributes_for :reagents, reject_if: lambda { |e| e[:name].blank? or e[:number].to_i <= 0 }, allow_destroy: true
  
  attr_accessor :reagent_list
  
  validates :equipment, :device, :kit, :target, presence: true
  validates :kit, uniqueness: { scope: [:equipment, :device] }
  
  def self.equipment equipment, equipment_kits
    assay_kits = {}
    # set unknown kit as default
    equipment_kits.each{ |kit| assay_kits[kit] = { kit: kit, reagents: ["unknown kit"]} }
    AssayKit.includes(:reagents).where(equipment: equipment, kit: equipment_kits).each do |assay_kit|
      assay_kits[assay_kit.kit] = { kit: assay_kit.device, reagents: assay_kit.reagents.map { |reagent| reagent.name } }
    end
    assay_kits
  end
  
  def reagent_list
    reagents.map { |reagent| reagent.id }
  end  
end
