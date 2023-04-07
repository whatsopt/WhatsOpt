# frozen_string_literal: true

class PackagePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.joins(:analysis).where(analyses: { id: Pundit.policy_scope!(@user, Analysis) })
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
    @user.admin? || @user.has_role?(:owner, @record.analysis)
  end
end
