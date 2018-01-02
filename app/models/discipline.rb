require 'whats_opt/openmdao_mapping'
require 'whats_opt/discipline'

class Discipline < ApplicationRecord
  
  include WhatsOpt::OpenmdaoModule
    
  has_many :variables, :dependent => :destroy
  
  belongs_to :multi_disciplinary_analysis
  #acts_as_list scope: :multi_disciplinary_analysis
  
  accepts_nested_attributes_for :variables, reject_if: proc { |attr| attr['name'].blank? }, allow_destroy: true

  validates :name, presence: true
  
  scope :driver, -> { where( kind: WhatsOpt::Discipline::NULL_DRIVER ) }
  scope :analyses, -> { where( kind: WhatsOpt::Discipline::ANALYSIS ) }

  after_initialize :set_defaults, unless: :persisted?  
    
  def input_variables
    self.variables.inputs
  end

  def output_variables
    self.variables.outputs
  end

  private
  
  def set_defaults
    self.kind = WhatsOpt::Discipline::ANALYSIS if self.kind.blank?
    if self.name == WhatsOpt::Discipline::NULL_DRIVER_NAME
      self.kind = WhatsOpt::Discipline::NULL_DRIVER
    end
  end
  
end
