class MachinePolicy < ApplicationPolicy
  
  class Scope < Scope
    
    def resolve
      found = super
      account.devices.find_each do |device|
        found = found.or scope.where(device: device.device, created_at: device.activated_at..device.to_deactivated)
      end
      found
    end
    
  end
  
end
