class OperationPolicy < ApplicationPolicy
    
  def update?
    @user.admin? or @user.has_role?(:owner, @record.analysis)
  end
  
  def destroy?
    @user.admin? or @user.has_role?(:owner, @record.analysis)
  end
  
end