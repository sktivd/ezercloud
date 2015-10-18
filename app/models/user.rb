class User < ActiveRecord::Base
  has_many :notifications, dependent: :destroy
  
  has_secure_password
  
  validates :name, presence: true, uniqueness: true
  validates :name, length: { in: 4..63 }
  validates :password, length: { in: 8..20 }
end
