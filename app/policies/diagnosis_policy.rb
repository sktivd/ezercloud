class DiagnosisPolicy < MachinePolicy
  
  def index?
    super || account.devices.any?
  end
  
  def map?
    account.has_role?(:admin) || account.has_role?(:monitorer, Diagnosis)
  end
    
end
