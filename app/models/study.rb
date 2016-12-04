require 'json'

class Study < ApplicationRecord
  resourcify

  belongs_to :project, :dependent => :destroy
  has_many :runs
  has_many :attachments, :as => :container
  accepts_nested_attributes_for :attachments, allow_destroy: true, reject_if: lambda { |a| a[:data].blank? }

  serialize :tree_json, JSON
  serialize :conns_json, JSON

  validates :project, presence: true

  after_initialize :post_initialize 


  private
  
  def post_initialize
    self.name = "Unnamed" if self.name.blank?
  end
  
end
