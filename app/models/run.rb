class Run < ApplicationRecord
  resourcify

  belongs_to :study, :dependent => :destroy
end
