class EquipmentPolicy < ApplicationPolicy  
  
  class Scope < Scope
    def resolve
      super.size > 0 ? super : Equipment.where(id: account.device_list.uniq.pluck(:equipment_id)).order(:equipment)
    end
  end
  
end
