class CommcareImage < ApplicationRecord
  belongs_to :commcare
  
  PERMITTED_VERSION = [1]

  validates :version, inclusion: { in: PERMITTED_VERSION, message: "is not invalid." }
  
  has_attached_file :image_file, url: "/assets/:class/:id/:basename.:extension", 
                                 path: ":rails_root/public/assets/:class/:id/:basename.:extension",
                                 preserve_files: false
  validates_attachment :image_file, size: { less_than: 20.megabytes }
  validates_attachment :image_file, content_type: { content_type: /\Aimage\/.*\z/ }
    
end
