# frozen_string_literal: true

class DesignProjectPolicy < ApplicationPolicy
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
    update?
  end

  def update?
    (@user.admin? || @user.has_role?(:owner, @record))
  end

  def destroy?
    @user.admin? || @user.has_role?(:owner, @record)
  end
end
