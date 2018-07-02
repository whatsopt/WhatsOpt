class UserPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
  
  def update?
    @user.admin? or @user.id == @record.id
  end
  
  def destroy?
    @user.admin? or @user.id == @record.id
  end
  
end