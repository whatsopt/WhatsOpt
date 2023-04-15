# frozen_string_literal: true

class OperationPolicy < ApplicationPolicy
  def enable_remote_operations?
    APP_CONFIG["enable_remote_operations"]
  end

  def show?
    enable_remote_operations? && AnalysisPolicy.new(@user, @record.analysis).show?
  end

  def create?
    enable_remote_operations? && @user.has_role?(:owner, @record.analysis)
  end

  def update?
    enable_remote_operations? && destroy?
  end

  def destroy?
    enable_remote_operations? && (@user.admin? || @user.has_role?(:owner, @record.analysis))
  end
end
