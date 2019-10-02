# frozen_string_literal: true

class GeometryModelPolicy < ApplicationPolicy

  def manage_geometry_models?
    APP_CONFIG['manage_geometry_models']
  end

  def create?
    manage_geometry_models?
  end

  def update?
    manage_geometry_models? && (@user.admin? || @user.has_role?(:owner, @record))
  end

  def destroy?
    manage_geometry_models? && (@user.admin? || @user.has_role?(:owner, @record))
  end
end
