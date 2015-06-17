class Diagnosis < ActiveRecord::Base
  belongs_to :diagnosable, polymorphic: true
  
  attr_accessor :authorized_key, :year, :month, :day, :hour, :minute, :second, :time_zone, :data
  
  VERSION = 1
  DATETIME_FIELDS = [:year, :month, :day, :hour, :minute, :second, :time_zone]
  MIN_YEAR = 2015
  MAX_YEAR = 2030
  
  validates :protocol, :equipment, :measured_at, presence: true
  validates :version,       numericality: { equal_to: VERSION }
  validates :elapsed_time,  allow_blank:true, numericality: { greater_than_or_equal_to: 0, message: "should be greater than or equal to 0" }
  validates :latitude,      allow_blank:true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude,     allow_blank:true, numericality: { greater_than_or_equal_to: -360, less_than_or_equal_to: 360 }
  validates :sex,           allow_blank:true, numericality: { integer_only: true, greater_than_or_equal_to: -1, less_than_or_equal_to: 2 }
  validates :age_band,      allow_blank:true, numericality: { integer_only: true, greater_than_or_equal_to: -1, less_than_or_equal_to: 9 }
  validate :check_protocol_name, :check_measured_time
  
  def check_protocol_name
    if protocol != 'SKYNET'
      errors.add(:protocol, "is invalid protocol")
    end
  end
  
  def check_measured_time
    if measured_at and (measured_at.year < MIN_YEAR or measured_at.year > MAX_YEAR)
      errors.add(:measured_at, measured_at.year.to_s + "is out of allowed year [" + MIN_YEAR.to_s + ", " + MAX_YEAR.to_s + "]")
    end
  end
  
end
