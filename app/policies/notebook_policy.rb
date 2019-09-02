# frozen_string_literal: true

class NotebookPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # if intranet?
      #   scope.all
      # else
        scope.none
      # end
    end
  end
  # def create?
  #   # intranet?
  # end

  # def update?
  #   # intranet? && (@user.admin? || @user.has_role?(:owner, @record))
  # end

  # def destroy?
  #   # intranet? && (@user.admin? || @user.has_role?(:owner, @record))
  # end
end
