class Frend < ActiveRecord::Base
  include EquipmentUtils  
  include NotificationUtils
  has_one :diagnosis, as: :diagnosable, dependent: :delete
  
  TEST_TYPE = ["Test", "External QC", "Internal QC"]
  
  VERSION = 1
  QC_MANAGED_DAYS = 365
  
  validates :serial_number, :test_type, :kit, :lot, presence: true
  validates :version,       numericality: { equal_to: VERSION, message: "should be matched to server's version" }  
  validates :qc_service, :qc_lot, presence: true, if: :external_qc?
# temporary does not check internal QC data 
#  validates :internal_qc_laser_power_test, :internal_qc_laseralignment_test, :internal_qc_calculated_ratio_test, :internal_qc_test, presence: true, if: :internal_qc? 

  def test_names
    test_id.split(":", 3).map { |value| Reagent.find_by(number: value).name if value and value != "" and value != "0" }.compact
  end
  
  def test_values
    available_id = test_id.split(":")
    test_result.split(":", 3).map.with_index { |value, index| "%.2f" % value.to_f if available_id[index] and available_id[index] != "" and available_id[index] != "0" }.compact
  end

  def notification    
    if test_type == 1
      notifications = []
      assay_kit = AssayKit.find_by(equipment: 'Frend', kit: kit)
      if assay_kit
        assay_kit.plates.each do |plate|
          if (test_id.split(':', 3) - ['0']).include?(plate.reagent.number) and plate.quality_control_materials.find_by(service: qc_service, lot: qc_lot).nil?
            User.where(privilege_reagent: true, privilege_notification: true, equipment_frends: true).each do |user|
              notifications.append({ follow: :response, tag: ['F', plate.id, qc_service[0], qc_lot].join, message: "Unregistered Quality Control material has been tested.\nPlease input QC material information!", every: 1.day, expired_at: 3.day.from_now, data: { equipment: 'FREND', assay_kit: AssayKit.find_by(kit: kit).device, reagent: plate.reagent.name, qc_service: qc_service, qc_lot: qc_lot, date: diagnosis.measured_at }, user: user, redirect_path: '/quality_control_materials/new', parameters: { quality_control_material: { equipment: 'FREND', plate_id: plate.id, service: qc_service, lot: qc_lot, expire: qc_expire } }, mailer: "new_qcmaterial" })
            end
          end
        end
      end
#      test_id.split(':', 3).map { |value| Reagent.find_by(number: value.to_i) if value.to_i != '0' }.compact.each do |reagent|
#        if QualityControlMaterial.find_by(service: qc_service, lot: qc_lot, reagent_id: reagent.id).nil?
#          User.where(privilege_reagent: true, privilege_notification: true).each do |user|
#            notifications.append({ follow: :response, tag: ['F', reagent.id, qc_service[0], qc_lot].join, message: "Unregistered Quality Control material has been tested.\nPlease input QC material information!", every: 1.day, expired_at: 3.day.from_now, data: { equipment: 'FREND', assay_kit: AssayKit.find_by(kit: kit).device, reagent: reagent.name, qc_service: qc_service, qc_lot: qc_lot, date: diagnosis.measured_at }, user: user, redirect_path: '/quality_control_materials/new', parameters: { quality_control_material: { equipment: 'FREND', reagent_id: reagent.id, service: qc_service, lot: qc_lot, expire: qc_expire } }, mailer: "new_qcmaterial" })
#          end
#        end
#      end
      
      notifications
    end
  end
 
#  def self.read
#    self.order(:created_at).reverse_order.includes(:diagnosis)
#  end
  
  private
  
    def external_qc?
      test_type == 1
    end
  
    def internal_qc?
      test_type == 2
    end
  
end
