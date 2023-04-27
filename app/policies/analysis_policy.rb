# frozen_string_literal: true

class AnalysisPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.roots
      else
        publicAnalyses = scope.where(public: true)
        authorizedAnalyses = scope.with_role([:owner, :member], user).preload(:roles)
        analyses = (publicAnalyses + authorizedAnalyses).uniq
        scope.where(id: analyses.map { |a| a[:id].to_i }).roots
      end
    end
  end

  def create?
    true
  end

  def show?
    @record.public || @user.admin? || @user.has_role?(:owner, @record) || @user.has_role?(:member, @record)
  end

  # Used in erb views templates
  def operate?
    APP_CONFIG["enable_remote_operations"] && destroy?
  end

  def unlock?
    @user.has_role?(:owner, @record)
  end

  def edit?
    @record.locked || update?
  end

  def update?
    !@record.locked && (@user.admin? || @user.has_role?(:owner, @record) || @user.has_role?(:co_owner, @record))
  end

  def destroy?
    !@record.locked && (@user.admin? || @user.has_role?(:owner, @record))
  end
end
