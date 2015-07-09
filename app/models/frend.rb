class Frend < ActiveRecord::Base
  has_one :diagnosis, as: :diagnosable, dependent: :destroy
  
  VERSION = 1
  
  validates :serial_number, :test_type, :device_id, :device_lot, presence: true
  validates :version,       numericality: { equal_to: VERSION, message: "should be matched to server's version" }  
  validates :qc_service, :qc_lot, presence: true, if: :external_qc?
  validates :internal_qc_laser_power_test, :internal_qc_laseralignment_test, :internal_qc_calcaulated_ratio_test, :internal_qc_test, presence: true, if: :internal_qc? 
  
  def external_qc?
    test_type == 1
  end

  def internal_qc?
    test_type == 2
  end
  
end
