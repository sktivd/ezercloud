class Specification < ActiveRecord::Base
  resourcify
  
  belongs_to :reagent
end
