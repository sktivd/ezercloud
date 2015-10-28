class QCMValidator < ActiveModel::Validator
  def validate(record)
    if record.send(:lower_3sd).to_f > record.send(:upper_3sd).to_f
      record.errors[:lower_3sd] << "larger than upper bound"
      record.errors[:upper_3sd] << "smaller than lower bound"
    end
  end
end

class QualityControlMaterial < ActiveRecord::Base
  belongs_to :reagent  

  attr_accessor :assay_kit, :lower_3sd, :upper_3sd
  
  validates :equipment, :reagent, :service, :lot, :expire, presence: true
  validates :lot, uniqueness: { scope: [:reagent, :service] }
  validate :expire, :already_expired?
  validates :mean, :sd, presence: true, unless: :threeSD?
  validates :mean, :sd, numericality: true, if: :mean_and_sd?
  validates :lower_3sd, :upper_3sd, presence: true, unless: :mean_and_sd?
  validates :lower_3sd, :upper_3sd, numericality: true, if: :threeSD?
  validates_with QCMValidator, fields: [:lower_3sd, :upper_3sd], if: :threeSD?
  
  SEVICES = ['BIO-RAD', 'CLINIQA']
  
  def assay_kit_label
    if self.reagent
      self.reagent.assay_kit.device
    elsif self.assay_kit
      AssayKit.find(self.assay_kit).device
    end
  end
  
  def reagent_label
    self.reagent.name if self.reagent
  end

  def reagent_unit
    if self.reagent
      ' (' + self.reagent.unit + ')'
    end
  end
  
  private
  
  def threeSD?
    lower_3sd and upper_3sd
  end

  def threeSD?
    lower_3sd and upper_3sd
  end

  def mean_and_sd?
    mean and sd
  end
  
  def already_expired?
    if expire <= Date.today
      errors.add(:expire, "can't be in the past")
    end
  end
end
