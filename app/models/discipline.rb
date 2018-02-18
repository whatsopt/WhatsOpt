require 'whats_opt/openmdao_module'
require 'whats_opt/discipline'

class Discipline < ApplicationRecord
  
  include WhatsOpt::Discipline
  include WhatsOpt::OpenmdaoModule
  
  self.inheritance_column = :disable_inheritance
    
  has_many :variables, :dependent => :destroy
  
  belongs_to :analysis
  acts_as_list scope: :analysis, top_of_list: 0
  
  accepts_nested_attributes_for :variables, reject_if: proc { |attr| attr['name'].blank? }, allow_destroy: true

  validates :name, presence: true, allow_blank: false
  
  scope :driver, -> { where( type: WhatsOpt::Discipline::NULL_DRIVER ) }
  scope :nodes, -> { where.not( type: WhatsOpt::Discipline::NULL_DRIVER ) }

  after_initialize :set_defaults, unless: :persisted?  
    
  def input_variables
    self.variables.inputs
  end

  def output_variables
    self.variables.outputs
  end

  private
  
  def set_defaults
    self.type = WhatsOpt::Discipline::ANALYSIS if self.type.blank?
    if self.name == WhatsOpt::Discipline::NULL_DRIVER_NAME
      self.type = WhatsOpt::Discipline::NULL_DRIVER
    end
  end
  
end
