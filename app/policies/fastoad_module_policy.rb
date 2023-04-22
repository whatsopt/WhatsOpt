# frozen_string_literal: true

class FastoadModulePolicy < ApplicationPolicy

  def show?
    FastoadConfig.new(@user, @record.fastoad_config).show?
  end

  def create?
    true
  end

  def update?
    destroy?
  end

  def destroy?
    (@user.admin?)
  end
end
