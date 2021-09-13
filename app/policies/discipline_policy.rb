# frozen_string_literal: true

class DisciplinePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.nodes
    end
  end
end
