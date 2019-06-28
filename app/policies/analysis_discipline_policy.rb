# frozen_string_literal: true

class AnalysisDisciplinePolicy < ApplicationPolicy
  def create?
    @user.admin? || (@user.has_role?(:owner, @record.discipline.analysis) &&
                     @user.has_role?(:owner, @record.analysis))
  end

  def destroy?
    @user.admin? || @user.has_role?(:owner, @record.discipline.analysis)
  end
end
