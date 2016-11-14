class Account < ActiveRecord::Base
  rolify

  has_many :devices, class_name: DeviceLicense
  has_many :notifications, dependent: :destroy
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # :registerable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable, :timeoutable, :invitable, timeout_in: 30.minutes, invite_for: 2.weeks
  
  attr_accessor :admin
  
  # previliges
  ROLES   = { viewer: 'Data Viewer', monitorer: 'Surveillance Monitorer', data_manager: 'Data Manager', device_manager: 'Device Manager' }
  FIELDS  = { viewer:  ['DiagnosisResult', 'PersonsHealth'], monitorer: ['DiagnosisResult'], data_manager: ['DiagnosisResult', 'PersonsHealth', 'Assay', 'QC', 'Notification', 'Report'], device_manager: ['Equipment'] }
  MODELS  = { DiagnosisResult: [Diagnosis], PersonsHealth: [Person], Equipment: [Equipment, Device, DeviceLicense], Assay: [AssayKit, Reagent, Plate], QC: [Laboratory, QualityControlMaterial], Notification: [Notification], Report: [Report] }
  OPTIONS = { viewer:  true, monitorer: false, data_manager: false, device_manager: false }
  
  def is_admin?
    self.has_role? :admin
  end
  
  def device_list
    Device.where id: devices.pluck(:device_id)
  end
   
end
