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
    true
  end

  def update?
    @user.has_role?(:owner, @record)
  end

  def destroy?
    @user.has_role?(:owner, @record)
  end
end
