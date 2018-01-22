class Notebook < ApplicationRecord
  resourcify
  
  has_one :attachment, :as => :container
  accepts_nested_attributes_for :attachment, allow_destroy: true,
                                reject_if: lambda { |a| a[:data].blank? }

  validates :title, presence: true
  validates :attachment, presence: true

  def owner
    owners = User.with_role(:owner, self)
    owners.first.login if owners.first
  end
  
end
