class Diagnosis < ActiveRecord::Base
  belongs_to :diagnosable, polymorphic: true
  
  attr_accessor :authentication_key, :year, :month, :day, :hour, :minute, :second, :time_zone, :data
  
  AUTHENTICATION_KEYS = {
    "1.234.62.144": "c049e9b8285c7837a0a25f1a91454dc131af2be5c7b92a8ea7aac12d9a749654d0fd61265cbacfb74c376e779dfb356b9865194695f1159dc7453eb742748362",
    "218.36.252.2": "c049e9b8285c7837a0a25f1a91454dc131af2be5c7b92a8ea7aac12d9a749654d0fd61265cbacfb74c376e779dfb356b9865194695f1159dc7453eb742748362",
    "127.0.0.1": "2310efe9757ffe2fc26666b1ee802aab96f5d924fc3676392fcb0fa329f20e5a62457b0bf34a253f69da28ace17fc96bfd741cff58b1730b13c700ccdd65b021",
    "121.136.101.241": "2310efe9757ffe2fc26666b1ee802aab96f5d924fc3676392fcb0fa329f20e5a62457b0bf34a253f69da28ace17fc96bfd741cff58b1730b13c700ccdd65b021",
    "220.103.225.254": "2310efe9757ffe2fc26666b1ee802aab96f5d924fc3676392fcb0fa329f20e5a62457b0bf34a253f69da28ace17fc96bfd741cff58b1730b13c700ccdd65b021"
  }
  
  VERSION = 1
  DATETIME_FIELDS = [:year, :month, :day, :hour, :minute, :second]
  TIMEZONE_FIELD  = :time_zone
  MIN_YEAR = 2014
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
