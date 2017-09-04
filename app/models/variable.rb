require 'whats_opt/openmdao_mapping'

class BadShapeAttributeError < StandardError
end

class Variable < ApplicationRecord

  include WhatsOpt::OpenmdaoVariable

  DEFAULT_SHAPE = '1' # either 'n', '(n,), (n, m) or (n, m, p)'
  DEFAULT_TYPE = FLOAT_T
    
  self.inheritance_column = :disable_inheritance
  belongs_to :discipline

  validates :name, :io_mode, :type, :shape, presence: true
  validates :name, uniqueness: { scope: [:discipline, :io_mode], message: "should be uniq per discipline and io mode." }
  validate  :shape_is_well_formed
      
  scope :inputs, -> { where(io_mode: IN) }
  scope :outputs, -> { where(io_mode: OUT) }
    
  after_initialize :set_defaults, unless: :persisted?

  def dim
    @dim ||=  case self.shape
              when /^(\d+)$/
                $1.to_i
              when /^\((\d+),\)$/ 
                $1.to_i
              when /^\((\d+), (\d+)\)$/
                $1.to_i * $2.to_i
              when /^\((\d+), (\d+), (\d+)\)$/
                $1.to_i * $2.to_i * $3.to_i
              else
                raise BadShapeAttributeError.new("should be either n, (n,), (n, m) or (n, m, p) but found #{self.shape}")
              end
  end
  
  private
  
  def set_defaults
    self.shape = DEFAULT_SHAPE unless self.shape
    self.type  = DEFAULT_TYPE unless self.type
  end

  def shape_is_well_formed
    begin
      self.dim
    rescue BadShapeAttributeError => e
      errors.add(:shape, "variable shape " + e.message)
    end
  end
end
