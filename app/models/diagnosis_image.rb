class DiagnosisImage < ActiveRecord::Base
#  belongs_to :imagable, polymorphic: true
  belongs_to :diagnosis_imagable, polymorphic: true

  attr_accessor :authentication_key, :remote_ip, :equipment, :anchor

  AUTHENTICATION_KEYS = {
    "1.234.62.144": "c049e9b8285c7837a0a25f1a91454dc131af2be5c7b92a8ea7aac12d9a749654d0fd61265cbacfb74c376e779dfb356b9865194695f1159dc7453eb742748362",
    "218.36.252.2": "c049e9b8285c7837a0a25f1a91454dc131af2be5c7b92a8ea7aac12d9a749654d0fd61265cbacfb74c376e779dfb356b9865194695f1159dc7453eb742748362",
    "127.0.0.1": "2310efe9757ffe2fc26666b1ee802aab96f5d924fc3676392fcb0fa329f20e5a62457b0bf34a253f69da28ace17fc96bfd741cff58b1730b13c700ccdd65b021",
    "121.136.101.241": "2310efe9757ffe2fc26666b1ee802aab96f5d924fc3676392fcb0fa329f20e5a62457b0bf34a253f69da28ace17fc96bfd741cff58b1730b13c700ccdd65b021",
    "220.103.225.254": "2310efe9757ffe2fc26666b1ee802aab96f5d924fc3676392fcb0fa329f20e5a62457b0bf34a253f69da28ace17fc96bfd741cff58b1730b13c700ccdd65b021"
  }

  PROTOCOL = ["SSIP"]
  VERSIONS = [1]

  validate  :check_authentication_key
  validates :protocol,  presence: true, inclusion: { in: PROTOCOL, message: "invalid" }
  validates :version,   presence: true, numericality: true, inclusion: { in: VERSIONS, message: "invalid" }
  validates :hash_code, presence: true, uniqueness: true

  has_attached_file :image_file, url: "/assets/:class/:id/:basename.:extension", 
                                 path: ":rails_root/public/assets/:class/:id/:basename.:extension",
                                 preserve_files: false,
                                 styles: {
                                   thumbnail: ["80x80>", :png],
                                   large:     ["200x200>", :png],
                                 }
  validates_attachment :image_file, presence: true
  validates_attachment :image_file, size: { less_than: 1.megabytes }
  validates_attachment :image_file, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif", "image/tiff", "image/tif", "image/bmp"] }

  private
  
    def check_authentication_key
      if authentication_key != AUTHENTICATION_KEYS[remote_ip]
        errors.add(:authentication, "invalid")
      end
    end
  
end
