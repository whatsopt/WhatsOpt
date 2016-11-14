require 'json'

class Study < ApplicationRecord
  resourcify

  belongs_to :project, :dependent => :destroy
  has_many :runs

  serialize :tree_json, JSON
  serialize :conns_json, JSON

  validates :project, presence: true 
end
