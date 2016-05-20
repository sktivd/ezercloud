class Plate < ActiveRecord::Base
  belongs_to :assay_kit
  belongs_to :reagent
  has_many :quality_control_materials, dependent: :destroy
  has_many :reports, dependent: :destroy
  
  accepts_nested_attributes_for :assay_kit, allow_destroy: true
end
