class NotebookPolicy < ApplicationPolicy

  def index?
    @true
  end
    
  def update?
    @user.admin? or @user.has_role?(:owner, @record)
  end
  
  def destroy?
    @user.admin? or @user.has_role?(:owner, @record)
  end
  
end