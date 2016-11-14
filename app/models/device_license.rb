class DeviceLicense < ActiveRecord::Base
  belongs_to :owner, class_name: Account, foreign_key: 'account_id'
  belongs_to :device
  
  attr_accessor :tag, :equipment_id, :serial_number, :note
  
  before_validation :set_activated, if: ->(obj){ obj.activated_at.nil? }
  before_validation :set_device,    if: ->(obj){ obj.device_id.nil? }
  
  validates :equipment_id, :serial_number, presence: true, if: ->(obj){ obj.device.nil? }

  def to_deactivated
    deactivated_at.nil? ? DateTime::Infinity.new : deactivated_at
  end

  def get_device
    device || Device.find_by(equipment_id: equipment_id, serial_number: serial_number) if equipment_id and serial_number
  end
    
  private
  
    def set_activated
      self.activated_at = DateTime.now
    end
    
    def set_device
      self.device = get_device
    end
        
end
