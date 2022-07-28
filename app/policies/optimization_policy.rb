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

  def index?
    show?
  end

  def show?
    (@user.admin? || @user.has_role?(:owner, @record))
  end

  def update?
    (@user.admin? || @user.has_role?(:owner, @record))
  end

  def destroy?
    (@user.admin? || @user.has_role?(:owner, @record))
  end

  def select?
    show?
  end

  def compare?
    show?
  end

  def download?
    show?
  end
end
