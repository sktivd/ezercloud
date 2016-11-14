module EquipmentUtils
  extend ActiveSupport::Concern  

  included do 

    def self.read
      self.order(:created_at).reverse_order.includes(:diagnosis)
    end
    
    def equipment
      Equipment.find_by(klass: self.class.to_s)
    end
    
    def decision
      'Suspended'
    end
    
    def tag
      assay_kit = AssayKit.find_by(equipment: equipment.equipment, kit: kit)
      (assay_kit.target if assay_kit) || 'NA'
    end
    
    private
    
      def map_device
        self.device = Device.find_or_create_by(serial_number: serial_number, equipment: Equipment.find_by(klass: self.class.to_s))
      end
    
  end
  
end