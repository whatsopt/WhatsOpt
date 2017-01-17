class Notebook < ApplicationRecord
  resourcify
  
  has_one :attachment, :as => :container
  accepts_nested_attributes_for :attachment, allow_destroy: true,
                                reject_if: lambda { |a| a[:data].blank? }

  validates :attachment, presence: true

  def owner
    User.with_role(:owner, self).first.login
  end
end
