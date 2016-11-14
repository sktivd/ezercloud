class EzerReader < ActiveRecord::Base
  include EquipmentUtils
  include NotificationUtils
  has_one    :diagnosis,        as: :diagnosable,        dependent: :delete
  has_many   :diagnosis_images, as: :diagnosis_imagable, dependent: :delete_all
  belongs_to :device

  resourcify

  VERSION = 1
  PARAMETERS = [:version, :manufacturer, :serial_number, :processed, :error_code, :kit_maker, :kit, :lot, :test_decision, :user_comment, :test_id, :test_result, :test_threshold, :patient_id, :weather, :temperature, :humidity, :measured_points, :point_intensities]
  
  before_validation :map_device 
  
  validates :device, presence: true
  validates :serial_number, :kit, :lot, presence: true
  validates :version,       numericality: { equal_to: VERSION, message: "should be matched to server's version" }  

  def decision
    case 
    when user_comment.match(/^[pP]/)
      'Positive'
    when user_comment.match(/^[nN]/)
      'Negative'
    when user_comment.match(/^[sS]/)
      'Suspended'
    else
      'Invalid'
    end
  end
  
  def image_window
    diagnosis_images.find_by(tag: 'window') || images[0]
  end
  
end
