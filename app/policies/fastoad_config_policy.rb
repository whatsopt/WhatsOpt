# frozen_string_literal: true

class FastoadConfigPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def create?
    true
  end

  def show?
    true
  end

  def edit?
    destroy?
  end

  def update?
    destroy?
  end

  def destroy?
    @user.admin? || @user.has_role?(:owner, @record)
  end
end
