module EquipmentUtils
  extend ActiveSupport::Concern  

  included do 
    def self.read
      self.order(:created_at).reverse_order.includes(:diagnosis)
    end
    
    def decision
    end
  end
  
end