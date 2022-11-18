# frozen_string_literal: true

class OptimizationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? || user.has_role?(:sego_expert, @record)
        scope.all
      else
        scope.with_role(:owner, user)
      end
    end
  end

  def create?
    true
  end

  def show?
    true
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
