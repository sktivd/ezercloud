class Person < ActiveRecord::Base
  include EncryptionKey
  
  resourcify
  
  before_validation :generate_code
  
  attr_encrypted :person,      key: :encryption_key
  attr_encrypted :given_name,  key: :encryption_key
  attr_encrypted :family_name, key: :encryption_key
  attr_encrypted :sex,         key: :encryption_key
  attr_encrypted :birthday,    key: :encryption_key
  attr_encrypted :phone,       key: :encryption_key
  attr_encrypted :email,       key: :encryption_key
  
  validates :code, presence: true, uniqueness: true
  
  has_attached_file :id_photo, url: "/assets/:class/:id/:basename.:extension", 
                               path: ":rails_root/public/assets/:class/:id/:basename.:extension",
                               preserve_files: false
  validates_attachment :id_photo, presence: true
  validates_attachment :id_photo, size: { less_than: 1.megabytes }
  validates_attachment :id_photo, content_type: { content_type: /\Aimage\/.*\z/ }
  
  resourcify
  
  private
  
    def generate_code
      self.code = Digest::SHA256.hexdigest(person + ENV['ATTR_VALIDATED_KEY'])
    end
end
