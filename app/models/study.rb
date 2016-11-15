require 'json'

class Study < ApplicationRecord
  resourcify

  belongs_to :project, :dependent => :destroy
  has_many :runs
  has_many :attachments

  serialize :tree_json, JSON
  serialize :conns_json, JSON

  validates :project, presence: true 
end
