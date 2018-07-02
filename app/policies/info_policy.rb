class InfoPolicy < ApplicationPolicy

  def changelog?
    true
  end

  def show?
    true
  end
    
end