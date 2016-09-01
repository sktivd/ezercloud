class Equipment < ActiveRecord::Base
  resourcify
  
  has_many :error_codes, dependent: :destroy
end
