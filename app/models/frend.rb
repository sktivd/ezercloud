class Frend < ActiveRecord::Base  
  include NotificationUtils
  has_one :diagnosis, as: :diagnosable, dependent: :destroy
  
  TEST_TYPE = ["Test", "External QC", "Internal QC"]
  
  VERSION = 1
  QC_MANAGED_DAYS = 365
  
  validates :serial_number, :test_type, :kit, :lot, presence: true
  validates :version,       numericality: { equal_to: VERSION, message: "should be matched to server's version" }  
  validates :qc_service, :qc_lot, presence: true, if: :external_qc?
  validates :internal_qc_laser_power_test, :internal_qc_laseralignment_test, :internal_qc_calculated_ratio_test, :internal_qc_test, presence: true, if: :internal_qc? 

  def test_names
    test_id.split(":", 3).map { |value| Reagent.find_by(number: value).name if value and value != "" and value != "0" }.compact
  end
  
  def test_values
    available_id = test_id.split(":")
    test_result.split(":", 3).map.with_index { |value, index| "%.2f" % value.to_f if available_id[index] and available_id[index] != "" and available_id[index] != "0" }.compact
  end
 
  def notification    
    if test_type == 1
      test_id.split(':', 3).map { |value| Reagent.find_by(number: value.to_i) if value.to_i != '0' }.compact.each do |reagent|
        if QualityControlMaterial.find_by(service: qc_service, lot: qc_lot, reagent_id: reagent.id).nil?
          User.where(privilege_reagent: true, privilege_notification: true).each do |user|
            @notification = generate_notification(follow: :response, tag: ['F', reagent.id, qc_service[0], qc_lot].join, message: "Unregistered Quality Control material has been tested.\nPlease input QC material information!", expired_at: 3.day.from_now, data: { equipment: 'FREND', assay_kit: AssayKit.find_by(kit: kit).device, reagent: reagent.name, qc_service: qc_service, qc_lot: qc_lot, date: diagnosis.measured_at }, user: user, path: '/quality_control_materials/new', method: :get, parameters: { quality_control_material: { equipment: 'FREND', reagent_id: reagent.id, service: qc_service, lot: qc_lot, expire: qc_expire } }, mailer: "new_qcmaterial")
          end
        end
      end
    end
  end

  def self.generate_notification params
    @notification = Notification.new(follow: Notification::TYPES[params[:follow]], message: params[:message], user_id: params[:user].id, data: params[:data].to_json)
    @notification.authentication_key = Digest::SHA256.hexdigest @notification.to_s

    if @notification.follow == Notification::TYPES[:response]
      @notification.set_url(params[:path], params[:method], params[:parameters])
      if params[:mailer]
          @notification.mailer = params[:mailer]
          @notification.email
      end
    end
    
    @notification.sent_at = DateTime.now
    if @notification.save
      @notification
    else
      nil
    end
  end
  
  private
  
    def external_qc?
      test_type == 1
    end
  
    def internal_qc?
      test_type == 2
    end
  
end
