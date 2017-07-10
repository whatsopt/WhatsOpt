require 'whats_opt/openmdao_mapping'

class BadShapeAttributeError < StandardException
end

class Variable < ApplicationRecord
  
  include WhatsOpt::OpenmdaoVariable
  
  self.inheritance_column = :disable_inheritance
  belongs_to :discipline

  validates :name, :io_mode, :type, :shape, presence: true
  validates :name, uniqueness: { scope: :io_mode, message: "should be named once per io mode" }
  validate :shape_is_well_formed
      
  scope :inputs, -> { where(io_mode: IN) }
  scope :outputs, -> { where(io_mode: OUT) }
    
  after_initialize :set_defaults, unless: :persisted?

  private
  
  def set_defaults
    self.shape  ||= '1'
    self.type ||= WhatsOpt::OpenmdaoVariable::FLOAT_T
  end
  
  def dim
    case self.shape
    when /^(\d+)$/
      $1.to_i
    when /^\((\d+),\)$/
      $1.to_i
    when /^\((\d+),(\d+)\)$/
      $1.to_i * $1.to_i
    else
      raise BadShapeAttributeException.new
    end
  end
  
  def shape_is_well_formed
    unless shape =~ /^(\d+)$/ || shape =~ /^\((\d+),\)$/ || shape =~ /^\((\d+),(\d+)\)$/
      errors.add(:shape, "must be an int or of the form (n, ) or (n, m)")
    end
  end
end
