class AccountPolicy < ApplicationPolicy
  
  def manage?
    account.has_role?(:admin) || (account == record)
  end
  
end
