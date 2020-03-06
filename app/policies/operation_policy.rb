# frozen_string_literal: true

class OperationPolicy < ApplicationPolicy
  def enable_remote_operations?
    APP_CONFIG["enable_remote_operations"]
  end

  def show?
    @record.analysis.public || @user.admin? || @user.has_role?(:owner, @record.analysis) || @user.has_role?(:member, @record.analysis)
  end

  def create?
    enable_remote_operations? && (@user.admin? || @record.analysis.public ||
                           @user.has_role?(:owner, @record.analysis) ||
                           @user.has_role?(:member, @record.analysis))
  end

  def update?
    (@user.admin? || @user.has_role?(:owner, @record.analysis))
  end

  def destroy?
    (@user.admin? || @user.has_role?(:owner, @record.analysis))
  end
end
