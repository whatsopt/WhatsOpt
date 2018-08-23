class AnalysisPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.select do |record|
          record.public or user.has_role?(:owner, record) or user.has_role?(:member, record) 
        end
      end
    end
  end
  
  def index?
    
  end
  
  def create?
    true
  end

  def show?
    @record.public or @user.admin? or @user.has_role?(:owner, @record) or @user.has_role?(:member, @record)
  end
  
  def operate?
    update?
  end
  
  def edit?
    update?
  end
  
  def update?
    @user.admin? or @user.has_role?(:owner, @record)
  end
  
  def destroy?
    @user.admin? or @user.has_role?(:owner, @record)
  end
  
end