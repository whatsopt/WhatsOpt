class OperationPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
    
  def update?
    @user.admin? or @user.has_role?(:owner, @record.analysis)
  end
  
  def destroy?
    @user.admin? or @user.has_role?(:owner, @record.analysis)
  end
  
end