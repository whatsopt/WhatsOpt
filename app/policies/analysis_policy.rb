class AnalysisPolicy < ApplicationPolicy

  def index?
    true
  end
  
  def create?
    true
  end
  
  def operate?
    update?
  end
  
  def edit?
    update?
  end
  
  def update?
    @user.admin? or @user.has_role?(:owner, @record)
  end
  
  def destroy?
    @user.admin? or @user.has_role?(:owner, @record)
  end
  
end