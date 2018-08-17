class AnalysisPolicy < ApplicationPolicy

  def index?
    true
  end
  
  def create?
    true
  end

  def show?
    @record.public or @user.admin? or @user.has_role?(:owner, @record) or @user.has_role?(:member, @record)
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