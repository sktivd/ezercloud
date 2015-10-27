class Report < ActiveRecord::Base
  belongs_to :reagent
  
  attr_accessor :reagent_number
  
  REPORT_URI = "https://www.ezercloud.com/api/server/qc/10/qcReport/qcReportReceiver"
  
  validates :equipment, :serial_number, :date, :reagent, presence: true
  validate :equipment, :registered_equipment?
  validate :date, :in_the_future?
  
  has_attached_file :document, url: "/assets/:class/:id/:basename.:extension", 
                               path: ":rails_root/public/assets/:class/:id/:basename.:extension",
                               preserve_files: false
  validates_attachment :document, presence: true
  validates_attachment :document, size: { less_than: 1.megabytes }
  validates_attachment :document, content_type: { content_type: ["application/pdf"] }
  
  private
  
  def registered_equipment?
    @equipment = Equipment.find_by(equipment: equipment)
    if @equipment.nil?
      errors.add(:equipment, "unregistered equipment")
    elsif Object.const_get(@equipment.klass).find_by(serial_number: serial_number).nil?
      errors.add(:serial_number, "unknown equipment")
    end
  end
  
  def in_the_future?
    if date > Date.today
      errors.add(:date, "can't be in the future")
    end
  end  
end
