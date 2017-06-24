require 'whats_opt/openmdao_mapping'

class Variable < ApplicationRecord
  
  include WhatsOpt::OpenmdaoVariable
  
  self.inheritance_column = :disable_inheritance
  belongs_to :discipline

  validates :name, :io_mode, :type, :dim, presence: true
  validates :name, uniqueness: { scope: :io_mode, message: "should be named once per io mode" }
  validates :dim, numericality: { only_integer: true, greater_than: 0 }
      
  scope :inputs, -> { where(io_mode: IN) }
  scope :outputs, -> { where(io_mode: OUT) }
    
  after_initialize :set_defaults, unless: :persisted?

  private
  
  def set_defaults
    self.dim  ||= 1
    self.type ||= WhatsOpt::OpenmdaoVariable::FLOAT_T
  end
  
end
