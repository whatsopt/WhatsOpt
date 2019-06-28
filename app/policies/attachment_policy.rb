# frozen_string_literal: true

class AttachmentPolicy < ApplicationPolicy
  def create?
    @user.admin? || @user.has_role?(:owner, @record.container)
  end

  def update?
    @user.admin? || @user.has_role?(:owner, @record.container)
  end

  def destroy?
    @user.admin? || @user.has_role?(:owner, @record.container)
  end
end
