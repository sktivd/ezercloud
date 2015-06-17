class Frend < ActiveRecord::Base
  has_one :diagnosis, as: :diagnosable, dependent: :destroy
  
  VERSION = 1
  
  validates :serial_number, :test_type, :processed, :device_id, :device_ln, presence: true
  validates :version,       numericality: { equal_to: VERSION, message: "should be matched to server's version" }  
  
end
