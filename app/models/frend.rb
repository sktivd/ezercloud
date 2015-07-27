class Frend < ActiveRecord::Base  
  has_one :diagnosis, as: :diagnosable, dependent: :destroy
  
  VERSION = 1
  QC_MANAGED_DAYS = 365
  
  validates :serial_number, :test_type, :kit, :lot, presence: true
  validates :version,       numericality: { equal_to: VERSION, message: "should be matched to server's version" }  
  validates :qc_service, :qc_lot, :qc_expire, presence: true, if: :external_qc?
  validates :internal_qc_laser_power_test, :internal_qc_laseralignment_test, :internal_qc_calcaulated_ratio_test, :internal_qc_test, presence: true, if: :internal_qc? 
  
  def external_qc?
    test_type == 1
  end

  def internal_qc?
    test_type == 2
  end
  
  def update_insert kit, service, lot, expire
    references = Laboratory.where(equipment: 'FREND', kit: kit)
    equipment = Equipment.find_by(equipment: 'FREND')
    frend_references = Frend.includes(:diagnosis).where(kit: kit, test_type: 1, qc_service:service, qc_lot: lot, diagnoses: {ip_address: references.map { |value| value.ip_address }, measured_at: QC_MANAGED_DAYS.days.ago...Date.today})
    assay_kit = AssayKit.find_by(equipment: 'FREND', kit: kit)
    
    if frend_references.size > 1
      tested_reagents = frend_references[0][(equipment.prefix + 'id').to_sym].split(':', -1).map { |value| value.to_i }

      processed = true
      assay_kit.reagents.each do |reagent|
        index = tested_reagents.index(reagent.number)
        frends = []
        frend_references.each { |frend| frends << frend[(equipment.prefix + 'result').to_sym].split(':', -1).map { |value| value.to_f }[index] if frend.processed }
        new_insert = {service: service, lot: lot, expire: expire, equipment: 'FREND', manufacturer: 'NanoEnTek', reagent_name: reagent.name, reagent_number: reagent.number, n_equipment: frend_references.map { |frend| frend.serial_number }.uniq.size, n_measurement: frends.length_without_nil(0), mean: frends.mean, sd: frends.sd}

        qcms = reagent.quality_control_materials
        if (qcm = qcms.find_by(service: service, lot: lot)).nil?
          processed &= ! reagent.quality_control_materials.create(new_insert).nil?
        else
          processed &= qcm.update(new_insert)
        end

      end
      
    end
  end
    
end
