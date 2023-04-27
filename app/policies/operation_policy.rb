# frozen_string_literal: true

class OperationPolicy < ApplicationPolicy
  def enable_remote_operations?
    APP_CONFIG["enable_remote_operations"]
  end

  def analysis_unlocked?
    !@record.analysis.locked
  end

  def show?
    AnalysisPolicy.new(@user, @record.analysis).show?
  end

  def create?
    enable_remote_operations? && analysis_unlocked? && @user.has_role?(:owner, @record.analysis)
  end

  def update?
    destroy?
  end

  def destroy?
    analysis_unlocked? && (@user.admin? || @user.has_role?(:owner, @record.analysis))
  end
end
