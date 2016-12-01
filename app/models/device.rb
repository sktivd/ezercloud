class Device < ActiveRecord::Base
  searchkick match: :word_start, searchable: [:serial_number, :equipment_id]
  
  resourcify
  
  belongs_to :equipment
  has_many :device_licenses
  has_many :diagnoses
  
  validates :serial_number, :equipment, presence: true
  validates :serial_number, uniqueness: { scope: [:equipment] }
  
end
