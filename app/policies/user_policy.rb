class UserPolicy < ApplicationPolicy

  def create?
    @user.admin?
  end
  
  def update?
    @user.admin? or @user.id == @record.id
  end
  
  def destroy?
    @user.admin? or @user.id == @record.id
  end
  
end