# frozen_string_literal: true

class DisciplinePolicy < ApplicationPolicy
  def update?
    @user.admin? || @user.has_role?(:owner, @record.analysis)
  end

  def destroy?
    @user.admin? || @user.has_role?(:owner, @record.analysis)
  end
end
