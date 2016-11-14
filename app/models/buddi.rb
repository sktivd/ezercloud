class Buddi < ActiveRecord::Base
  include EquipmentUtils
  include NotificationUtils
  
  has_one    :diagnosis,        as: :diagnosable,        dependent: :delete
  has_many   :diagnosis_images, as: :diagnosis_imagable, dependent: :delete_all
  belongs_to :device

  resourcify

  VERSION = 1
  PARAMETERS = [:version, :manufacturer, :serial_number, :processed, :error_code, :kit, :lot, :device_expired_date, :patient_id, :test_zone_data, :control_zone_data, :ratio_data, :measured_points, :point_intensities]
  
  before_validation :map_device 
  
  validates :device, presence: true
  validates :serial_number, :kit, :lot, presence: true
  validates :version, numericality: { equal_to: VERSION, message: "should be matched to server's version" }  

#  def self.read
#    self.order(:created_at).reverse_order.includes(:diagnosis)
#  end

  # tag: result/original
  def tag
    'Influenza'
  end
  
  def image_window
    diagnosis_images.find_by(tag: 'result') || images[0]
  end

end
