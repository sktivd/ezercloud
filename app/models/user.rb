class User < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :name, length: { in: 4..63 }
  validates :password, length: { in: 8..20 }
  has_secure_password
end
