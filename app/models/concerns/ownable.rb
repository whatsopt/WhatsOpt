# frozen_string_literal: true

# Assumption: only one owner
module Ownable
  def owner
    owners = User.with_role_for_instance(:owner, self)
    owners.take
  end

  def readers
    readers = User.with_role_for_instance(:owner, self)
    readers |= members
    readers
  end

  def members
    User.with_role_for_instance(:member, self)
  end

  def set_owner(user)
    _remove_role(owner, :owner) if owner
    _add_role(user, :owner)
  end

  def add_member(user)
    _add_role(user, :member) unless user == self.owner
  end

  def remove_member(user)
    _remove_role(user, :member)
  end

  def copy_membership(ownable_src)
    ownable_src.readers.each do |r|
      self.add_member(r) 
    end
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
