require 'json'

class Study < ApplicationRecord
  resourcify

  belongs_to :project, :dependent => :destroy
  has_many :run

  serialize :tree_json, JSON
  serialize :conns_json, JSON
end
