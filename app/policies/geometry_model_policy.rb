class GeometryModelPolicy < ApplicationPolicy

  def create?
    intranet?
  end

  def update?
    intranet? && (@user.admin? or @user.has_role?(:owner, @record))
  end
  
  def destroy?
    intranet? && (@user.admin? or @user.has_role?(:owner, @record))
  end
  
end