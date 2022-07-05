# frozen_string_literal: true

class OptimizationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.with_role(:owner, user)
    end
  end

  def create?
    true
  end

  def show?
    (@user.admin? || @user.has_role?(:owner, @record) || @user.has_role?(:co_owner, @record))
  end

  def update?
    (@user.admin? || @user.has_role?(:owner, @record) || @user.has_role?(:co_owner, @record))
  end

  def destroy?
    (@user.admin? || @user.has_role?(:owner, @record) || @user.has_role?(:co_owner, @record))
  end

  def destroy_selected?
    (@user.admin? || @user.has_role?(:owner, @record) || @user.has_role?(:co_owner, @record))
  end
end
