class EzerReader < ActiveRecord::Base
  include EquipmentUtils
  include NotificationUtils
  has_one  :diagnosis,        as: :diagnosable,        dependent: :delete
  has_many :diagnosis_images, as: :diagnosis_imagable, dependent: :delete_all

  VERSION = 1

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
