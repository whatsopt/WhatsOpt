require 'json'

class Study < ApplicationRecord
  resourcify

  belongs_to :project, :dependent => :destroy
  
  has_many :attachments, :as => :container
  accepts_nested_attributes_for :attachments, allow_destroy: true,
                                reject_if: lambda { |a| a[:data].blank? }

  serialize :tree_json, JSON
  serialize :conns_json, JSON

  validates :project, presence: true
  validates :attachments, presence: true

  scope :with_notebooks, -> { joins(:attachments).where(attachments: {category: 'Notebook'}) } 

  # FIXME: implement has_many attachments but for the time being use just one
  def attachment
    attachments.first
  end
  
  def has_notebook?
    res =  Study.with_notebooks.where('studies.id = ?', id).to_a
    !res.empty?
  end

  def has_openmdao_problem?
    false
  end
  
  private
  
end
