class Diagnosis < ActiveRecord::Base
  belongs_to :diagnosable, polymorphic: true
  
  attr_accessor :authorized_key, :year, :month, :day, :hour, :minute, :second, :time_zone, :data
  
  VERSION = 1
  DATETIME_FIELDS = [:year, :month, :day, :hour, :minute, :second, :time_zone]
  MIN_YEAR = 2015
  MAX_YEAR = 2030
  
  validates :protocol, :equipment, presence: true
  validates :version,       numericality: { equal_to: VERSION }
  validates :elapsed_time,  numericality: { greater_than_or_equal_to: 0 }
  validates :latitude,      numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude,     numericality: { greater_than_or_equal_to: -360, less_than_or_equal_to: 360 }
  validates :sex,           numericality: { integer_only: true, greater_than_or_equal_to: -1, less_than_or_equal_to: 2 }
  validates :age_band,      numericality: { integer_only: true, greater_than_or_equal_to: -1, less_than_or_equal_to: 9 }
  validates_each :protocol do |record, attr, value|
    record.errors.add(attr, 'Invalid protocol') unless value == 'SKYNET'
  end
  
end
