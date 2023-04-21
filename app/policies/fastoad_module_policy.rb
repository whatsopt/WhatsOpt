# frozen_string_literal: true

class FastoadModulePolicy < ApplicationPolicy

  def show?
    FastoadConfig.new(@user, @record.fastoad_config).show?
  end

  def create?
    @user.has_role?(:owner, @record.fastoad_config)
  end

  def update?
    destroy?
  end

  def destroy?
    (@user.admin? || @user.has_role?(:owner, @record.fastoad_config))
  end
end
