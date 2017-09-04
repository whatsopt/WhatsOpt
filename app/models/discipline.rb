require 'whats_opt/openmdao_mapping'

class Discipline < ApplicationRecord
  
  include WhatsOpt::OpenmdaoModule
  
  CONTROL_NAME = '__CONTROL__'
  
  has_many :variables, :dependent => :destroy
  belongs_to :multi_disciplinary_analysis
  accepts_nested_attributes_for :variables, reject_if: proc { |attr| attr['name'].blank? }, allow_destroy: true

  validates :name, presence: true
  
  scope :as_control, -> { where( name: CONTROL_NAME ) }
  scope :plain, -> { where.not( name: CONTROL_NAME ) }

  def input_variables
    self.variables.inputs
  end

  def output_variables
    self.variables.outputs
  end

end
