class User < ActiveRecord::Base
  has_many :notifications, dependent: :destroy  
  has_secure_password
  attr_accessor :current_password
    
  validates :name, presence: true, uniqueness: true
  validates :name, length: { in: 4..63 }
  validates :password, length: { in: 8..20 }, if: -> { password.present? }
  validates :password, length: { in: 8..20 }, allow_blank: true
  validates :email, presence: true, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }    
end
