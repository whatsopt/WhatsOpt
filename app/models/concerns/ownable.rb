# frozen_string_literal: true

# Assumption: only one owner
module Ownable
  def owner
    @owner ||= User.with_role_for_instance(:owner, self).take
  end

  def readers
    @readers ||= User.with_role_for_instance(:owner, self) | members
  end

  def updaters
    @updaters ||= User.with_role_for_instance(:owner, self) | co_owners
  end

  def members
    @members ||= User.with_role_for_instance(:member, self)
  end

  def co_owners
    @co_owners ||= User.with_role_for_instance(:co_owner, self)
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
    _remove_role(user, :co_owner)
  end

  def add_co_owner(user)
    _add_role(user, :co_owner) unless user == self.owner
    _add_role(user, :member) unless user == self.owner
  end

  def remove_co_owner(user)
    _remove_role(user, :co_owner)
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
