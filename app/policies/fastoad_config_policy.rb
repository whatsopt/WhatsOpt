# frozen_string_literal: true

class FastoadConfigPolicy < ApplicationPolicy

  def enable_fastoad?
    APP_CONFIG["enable_fastoad"]
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def create?
    enable_fastoad? && true
  end

  def show?
    enable_fastoad? && true
  end

  def edit?
    enable_fastoad? && destroy?
  end

  def update?
    enable_fastoad? && destroy?
  end

  def destroy?
    enable_fastoad? && (@user.admin? || @user.has_role?(:owner, @record))
  end
end
