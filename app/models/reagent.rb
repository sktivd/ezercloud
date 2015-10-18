class Reagent < ActiveRecord::Base
  belongs_to :assay_kit
  has_many :quality_control_materials, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_one :specification
end
