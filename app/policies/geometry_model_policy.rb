# frozen_string_literal: true

class GeometryModelPolicy < ApplicationPolicy
  def create?
    intranet?
  end

  def update?
    intranet? && (@user.admin? || @user.has_role?(:owner, @record))
  end

  def destroy?
    intranet? && (@user.admin? || @user.has_role?(:owner, @record))
  end
end
