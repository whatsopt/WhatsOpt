# frozen_string_literal: true

# Assumption: only one owner
module Ownable
  def owner
    owners = User.with_role_for_instance(:owner, self)
    owners.take
  end

  def members
    members = User.with_role(:admin)
    members |= User.with_role_for_instance(:owner, self)
    members |= User.with_role_for_instance(:member, self)
    members
  end

  def set_owner(user) 
    _remove_role(owner, :owner) if owner
    _add_role(user, :owner)
  end

  def add_member(user)
    _add_role(user, :member)
  end

  def remove_member(user)
    _remove_role(user, :member)
  end

  # superseded by has_ancestry call in analysis
  def descendants
    []
  end

  private
    def _add_role(user, role)
      user.add_role(role, self)
      descendants.each { |mda| user.add_role(role, mda) }
    end

    def _remove_role(user, role)
      user.remove_role(role, self)
      descendants.each { |mda| user.remove_role(role, mda) }
    end
end
