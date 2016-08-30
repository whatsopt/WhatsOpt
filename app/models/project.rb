class Project < ActiveRecord::Base
  resourcify

  has_many :studies
end
