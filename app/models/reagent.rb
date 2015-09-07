class Reagent < ActiveRecord::Base
  belongs_to :assay_kits
  has_many :quality_control_materials, dependent: :destroy
  has_one :specification
end
