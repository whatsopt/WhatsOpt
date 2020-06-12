# frozen_string_literal: true

class MetaModelPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user.admin?
        scope
      else
        scope.where.not(id: scope.joins(:meta_model_prototype))
             .joins(:discipline).where(disciplines: {analysis_id: AnalysisPolicy::Scope.new(user, Analysis).resolve})
      end
    end
  end

  def show?
    @record.analysis.public || @user.admin? || @user.has_role?(:owner, @record.analysis) || @user.has_role?(:member, @record.analysis)
  end

  def create?
    @user.admin? || @record.analysis.public || @user.has_role?(:owner, @record.analysis) || @user.has_role?(:member, @record.analysis)
  end

  def update?
    # @user.admin? || @user.has_role?(:owner, @record.analysis)
    true
  end

  def destroy?
    @user.admin? || @user.has_role?(:owner, @record.analysis)
  end
end
