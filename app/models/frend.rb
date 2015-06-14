class Frend < ActiveRecord::Base
  has_one :diagnosis, as: :diagnosable, dependent: :destroy
end
