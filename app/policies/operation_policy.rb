class OperationPolicy < ApplicationPolicy

  def create?
    @user.admin? or @user.has_role?(:owner, @record.analysis)
  end
   
  def update?
    @user.admin? or @user.has_role?(:owner, @record.analysis)
  end
  
  def destroy?
    @user.admin? or @user.has_role?(:owner, @record.analysis)
  end
  
end