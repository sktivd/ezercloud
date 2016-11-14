class MachinePolicy < ApplicationPolicy
  
  class Scope < Scope
    def resolve
      if super.size > 0
        super
      else
        found = scope.none
        account.devices.find_each do |device|
          found = found.or scope.where(device: device.device, created_at: device.activated_at..device.to_deactivated)
        end
        found
      end
    end
  end
  
end
