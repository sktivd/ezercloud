class Diagnosis < ActiveRecord::Base
  include EncryptionKey  
  
  resourcify
  
  belongs_to :diagnosable, polymorphic: true
  belongs_to :device
  
  attr_accessor :authentication_key, :remote_ip, :year, :month, :day, :hour, :minute, :second, :time_zone, :data
  attr_encrypted :person, key: :encryption_key
  
  AUTHENTICATION_KEYS = {
    "1.234.62.144": "c049e9b8285c7837a0a25f1a91454dc131af2be5c7b92a8ea7aac12d9a749654d0fd61265cbacfb74c376e779dfb356b9865194695f1159dc7453eb742748362",
    "218.36.252.2": "c049e9b8285c7837a0a25f1a91454dc131af2be5c7b92a8ea7aac12d9a749654d0fd61265cbacfb74c376e779dfb356b9865194695f1159dc7453eb742748362",
    "127.0.0.1": "2310efe9757ffe2fc26666b1ee802aab96f5d924fc3676392fcb0fa329f20e5a62457b0bf34a253f69da28ace17fc96bfd741cff58b1730b13c700ccdd65b021",
    "121.136.101.241": "2310efe9757ffe2fc26666b1ee802aab96f5d924fc3676392fcb0fa329f20e5a62457b0bf34a253f69da28ace17fc96bfd741cff58b1730b13c700ccdd65b021",
    "220.103.225.254": "2310efe9757ffe2fc26666b1ee802aab96f5d924fc3676392fcb0fa329f20e5a62457b0bf34a253f69da28ace17fc96bfd741cff58b1730b13c700ccdd65b021"
  }
  
  # PROTOCOL SKYNET is deprecated
  PROTOCOL = ["SKYNET", "SSCP"]
  # VERSION 1 is deprecated
  VERSIONS = [1, 2]
  MIN_YEAR = 2014
  MAX_YEAR = 2030

  before_validation :set_measured_at, if: -> obj{ obj.measured_at.nil? }
  
  validates :equipment, :measured_at, :remote_ip, presence: true
  validates :protocol, presence: true, inclusion: { in: PROTOCOL, message: "invalid" }
  validates :version,  presence: true, numericality: true, inclusion: { in: VERSIONS, message: "invalid" }

  validates :elapsed_time,  allow_blank:true, numericality: { greater_than_or_equal_to: 0, message: "should be greater than or equal to 0" }
  validates :latitude,      allow_blank:true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude,     allow_blank:true, numericality: { greater_than_or_equal_to: -360, less_than_or_equal_to: 360 }
  validate  :check_authentication_key
  validate  :check_measured_time

  geocoded_by :location_or_ip_address
  after_validation :geocode, if: ->(obj){ obj.latitude.nil? or obj.longitude.nil? }
  
  def measurement
    Object.const_get(diagnosable_type).find(diagnosable_id)
  end
  
  private
  
    def check_authentication_key
      if authentication_key != AUTHENTICATION_KEYS[remote_ip]
        errors.add(:authentication, "invalid")
      end
    end
    
    def check_measured_time
      if measured_at and (measured_at.year < MIN_YEAR or measured_at.year > MAX_YEAR)
        errors.add(:measured_at, measured_at.year.to_s + "is out of allowed year [" + MIN_YEAR.to_s + ", " + MAX_YEAR.to_s + "]")
      end
    end
    
    def set_measured_at
      self.measured_at = DateTime.new year.to_i, month.to_i, day.to_i, hour.to_i, minute.to_i, second.to_i, time_zone
    end  
    
    def self.read
      self.order(:created_at).reverse_order
    end
    
    def location_or_ip_address
      geocode_by_location   = Geocoder.search(location)
      geocode_by_ip_address = Geocoder.search(ip_address)
      if geocode_by_location.size > 0
        self.latitude  = geocode_by_location[0].latitude
        self.longitude = geocode_by_location[0].longitude
      elsif geocode_by_ip_address.size > 0
        self.latitude  = geocode_by_ip_address[0].latitude
        self.longitude = geocode_by_ip_address[0].longitude
      end
    end
  
end
