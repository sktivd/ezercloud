class ApplicationPolicy
  attr_reader :account, :record

  def initialize(account, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless account
    @account = account
    @record  = record
  end

  def index?
    #false
    manage?
  end

  def show?
    #scope.where(:id => record.id).exists?
    manage?
  end
  
  def create?
    #false
    manage?
  end

  def new?
    #create?
    manage?
  end

  def update?
    #false
    manage?
  end

  def edit?
    #update?
    manage?
  end

  def destroy?
    #false
    manage?
  end

  def manage?
    account.has_role?(:admin) || account.has_role?(:data_manager, record) || account.has_role?(:device_manager, record)
  end

  def scope
    Pundit.policy_scope!(account, record.class)
  end

  class Scope
    attr_reader :account, :scope

    def initialize(account, scope)
      @account = account
      @scope   = scope
    end

    def resolve
      account.has_role?(:admin) || account.has_role?(:data_manager, scope) || account.has_role?(:device_manager, scope) ? scope.all : scope.none
    end
  end
  
end
