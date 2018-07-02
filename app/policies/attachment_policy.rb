class AttachmentPolicy < ApplicationPolicy

  def create?
    @user.admin? or @user.has_role?(:owner, @record.container)
  end
  
  def update?
    @user.admin? or @user.has_role?(:owner, @record.container)
  end
  
  def destroy?
    @user.admin? or @user.has_role?(:owner, @record.container)
  end
  
end