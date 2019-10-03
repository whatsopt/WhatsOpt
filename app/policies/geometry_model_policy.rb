# frozen_string_literal: true

class GeometryModelPolicy < ApplicationPolicy

  def enable_geometry_models?
    APP_CONFIG['enable_geometry_models']
  end

  def create?
    enable_geometry_models?
  end

  def update?
    enable_geometry_models? && (@user.admin? || @user.has_role?(:owner, @record))
  end

  def destroy?
    enable_geometry_models? && (@user.admin? || @user.has_role?(:owner, @record))
  end
end
