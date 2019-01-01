module Ownable

  def owner
    owners = User.with_role_for_instance(:owner, self)
    owners.take
  end

end
