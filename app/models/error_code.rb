class ErrorCode < ActiveRecord::Base
  resourcify
  
  belongs_to :equipment
end
