class AnalysisDisciplinePolicy < ApplicationPolicy

  def create?
    @user.admin? or (@user.has_role?(:owner, @record.discipline.analysis) &&
                     @user.has_role?(:owner, @record.analysis))
  end
    
  def destroy?
    @user.admin? or @user.has_role?(:owner, @record.discipline.analysis)
  end

end