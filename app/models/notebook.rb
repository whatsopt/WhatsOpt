class Notebook < ApplicationRecord
  resourcify
  
  include Ownable

  has_one :attachment, :as => :container
  accepts_nested_attributes_for :attachment, allow_destroy: true,
                                reject_if: lambda { |a| a[:data].blank? }

  validates :title, presence: true
  validates :attachment, presence: true
  
end
