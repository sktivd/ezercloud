class Reagent < ActiveRecord::Base
  has_many :assay_kits, through: :plates
  has_many :plates
  has_one :specification

  validates :equipment, :number, presence: true
  validates :number, uniqueness: { scope: [:equipment] } 
  
  before_destroy :ensure_not_referenced_by_any_plate

  def label
    name + ' (' + number.to_s + ')'
  end

  private
    def ensure_not_referenced_by_any_plate
      if plates.empty?
        return true 
      else
        errors.add(:base, 'Plates present')
        return false 
      end
    end
end
