require 'whats_opt/openmdao_mapping'
require 'whats_opt/discipline'

class Discipline < ApplicationRecord
  
  include WhatsOpt::OpenmdaoModule
  
  has_many :variables, :dependent => :destroy
  belongs_to :multi_disciplinary_analysis
  accepts_nested_attributes_for :variables, reject_if: proc { |attr| attr['name'].blank? }, allow_destroy: true

  validates :name, presence: true
  
  scope :driver, -> { where( name: WhatsOpt::Discipline::DRIVER_NAME ) }
  scope :analyses, -> { where.not( name: WhatsOpt::Discipline::DRIVER_NAME ) }

  def input_variables
    self.variables.inputs
  end

  def output_variables
    self.variables.outputs
  end

end
