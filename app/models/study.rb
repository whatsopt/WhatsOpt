class Study < ApplicationRecord
  resourcify

  belongs_to :project, :dependent => :destroy
  has_many :run
end
