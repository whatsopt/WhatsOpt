# frozen_string_literal: true

class OperationPolicy < ApplicationPolicy
  def manage_operations?
    APP_CONFIG['manage_operations']
  end

  def create?
    manage_operations? && (@user.admin? || @record.analysis.public || 
                           @user.has_role?(:owner, @record.analysis) || 
                           @user.has_role?(:member, @record.analysis))
  end

  def update?
    manage_operations? && (@user.admin? || @user.has_role?(:owner, @record.analysis))
  end

  def destroy?
    manage_operations? && (@user.admin? || @user.has_role?(:owner, @record.analysis))
  end
end
