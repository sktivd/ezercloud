class Equipment < ActiveRecord::Base
  has_many :error_codes, dependent: :destroy
end
