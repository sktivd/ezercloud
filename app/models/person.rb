class Person < ActiveRecord::Base
  include EncryptionKey
  include HasBarcode
  include URLParameters
  
  resourcify
  
  has_many :commcares, dependent: :destroy
  has_many :diagnoses
  
  has_barcode :barcode, outputter: :svg, type: :code_128, value: Proc.new { |p| p.person }
  
  attr_accessor :qrcode
    
  PERMITTED_VERSION = [1]
    
  before_validation :set_code
  
  attr_encrypted :person,      key: :encryption_key
  attr_encrypted :given_name,  key: :encryption_key
  attr_encrypted :family_name, key: :encryption_key
  attr_encrypted :sex,         key: :encryption_key
  attr_encrypted :birthday,    key: :encryption_key
  attr_encrypted :phone,       key: :encryption_key
  attr_encrypted :email,       key: :encryption_key
  
  validates :code,    presence: true, uniqueness: true
  validates :person,  presence: true
  validates :version, inclusion: { in: PERMITTED_VERSION, message: "is not invalid." }
  
  has_attached_file :id_photo, url: "/assets/:class/:id/:basename.:extension", 
                               source_file_options: { all: '-auto-orient' },
                               style: { large: "1600x900>", medium: "400x300>", thumb: "100x75>" },
                               path: ":rails_root/public/assets/:class/:id/:basename.:extension",
                               preserve_files: false
  validates_attachment :id_photo, size: { less_than: 20.megabytes }
  validates_attachment :id_photo, content_type: { content_type: /\Aimage\/.*\z/ }
  
  before_save :set_name, if: ->obj{ obj.given_name.nil? }
  
  def full_name
    (family_name + ", " + given_name if family_name) || given_name
  end
  
  def direct_url options = {}
    formatted_query = Rack::Utils.build_nested_query(person: { hash: code })
    # scheme, userinfo, host, port, registry, path, opaque, query, fragment
    URI::HTTP.new(SCHEME, nil, HOSTNAME, PORT, nil, '/people/person.' + ((options[:format].to_s if options[:format]) || '.html'), nil, formatted_query, nil).to_s
  end
  
  def qrcode options = { offset: 0, color: '000', shape_rendering: 'crispEdges', module_size: 3.5 }
    RQRCode::QRCode.new(direct_url).as_svg(options)
  end
  
  def body_index
    commcares.find_by(name: 'Body Growth')
  end
  
  def medical_checkup
  end
    
  class << self
    def find_person person_id
      find_by(code: generate_code_by(person_id))
    end
  
    private
  
    def generate_code_by person_id
      Digest::SHA256.hexdigest(person_id.to_s + ENV['ATTR_VALIDATED_KEY'])
    end
  end
  
  private
    
    def set_code
      self.code = Digest::SHA256.hexdigest(person.to_s + ENV['ATTR_VALIDATED_KEY'])
    end
    
    def set_name
      self.given_name = ""
    end
            
end
