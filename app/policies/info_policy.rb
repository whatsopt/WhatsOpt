# frozen_string_literal: true

class InfoPolicy < ApplicationPolicy
  def changelog?
    true
  end

  def show?
    true
  end
end
