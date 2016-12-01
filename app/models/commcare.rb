class Commcare < ApplicationRecord
  include EncryptionKey
  
  has_many :commcare_images, dependent: :destroy
  belongs_to :person
  
  PERMITTED_VERSION = [1]
      
  attr_encrypted :raw,                  key: :encryption_key
  attr_encrypted :agreement_signature,  key: :encryption_key
   
  validates :version, inclusion: { in: PERMITTED_VERSION, message: "is not invalid." }
  validates :form,    uniqueness: true
     
end
