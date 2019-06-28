# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def create?
    @user.admin?
  end

  def update?
    @user.admin? || (@user.id == @record.id)
  end

  def destroy?
    @user.admin? || (@user.id == @record.id)
  end
end
