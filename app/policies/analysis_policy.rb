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

  def operate?
    APP_CONFIG["enable_remote_operations"] && destroy?
  end

  def edit?
    update?
  end

  def update?
    (@user.admin? || @user.has_role?(:owner, @record) || @user.has_role?(:co_owner, @record))
  end

  def destroy?
    @user.admin? || @user.has_role?(:owner, @record)
  end
end
