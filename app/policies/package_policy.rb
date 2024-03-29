# frozen_string_literal: true

class PackagePolicy < ApplicationPolicy
  def enable_wopstore?
    APP_CONFIG["enable_wopstore"]
  end

  def analysis_unlocked?
    !@record.analysis.locked
  end

  class Scope < Scope
    def resolve
      scope.joins(:analysis).where(analyses: { id: Pundit.policy_scope!(@user, Analysis) })
    end
  end

  # Only the owner of the corresponding analysis can create package
  def create?
    enable_wopstore? && @user.has_role?(:owner, @record.analysis)
  end

  # Same rights as the corresponding analysis
  def show?
    enable_wopstore? && AnalysisPolicy.new(@user, @record.analysis).show?
  end

  def edit?
    destroy?
  end

  def update?
    destroy?
  end

  # Admin can destroy edit/update/destroy packages
  def destroy?
    enable_wopstore? && analysis_unlocked? && (@user.admin? || create?)
  end
end
