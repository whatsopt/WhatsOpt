require 'whats_opt/variable'
require 'whats_opt/openmdao_variable'

class BadShapeAttributeError < StandardError
end

class Variable < ApplicationRecord

  include WhatsOpt::Variable
  include WhatsOpt::OpenmdaoVariable

  DEFAULT_SHAPE = '1' # either 'n', '(n,), (n, m) or (n, m, p)'
  DEFAULT_TYPE = FLOAT_T
  DEFAULT_IOMODE = IN
    
  self.inheritance_column = :disable_inheritance
  belongs_to :discipline
  has_one :parameter
  has_one  :incoming_connection, -> { includes :from }, class_name: 'Connection', foreign_key: 'to_id', dependent: :destroy 
  has_many :outgoing_connections, -> { includes :to }, class_name: 'Connection', foreign_key: 'from_id', dependent: :destroy
    
  accepts_nested_attributes_for :parameter, reject_if: proc { |attr| attr['init'].blank? }, allow_destroy: true

  validates :name, :io_mode, :type, :shape, presence: true, allow_blank: false
  validates :name, uniqueness: { scope: [:discipline, :io_mode], message: "should be uniq per discipline and io mode." }
  validate  :shape_is_well_formed
      
  scope :numeric, -> { where.not(type: STRING_T) }
  scope :inputs, -> { numeric.where(io_mode: IN) }
  scope :outputs, -> { numeric.where(io_mode: OUT) }
  scope :objectives, -> { numeric.where("name LIKE '#{OBJECTIVE_PREFIX}%'") }
  scope :constraints, -> { numeric.where("name LIKE '#{CONSTRAINT_PREFIX}%'") }
    
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
    self.fullname = self.name if self.fullname.blank?
    self.io_mode = DEFAULT_IOMODE if self.io_mode.blank?
    self.shape = DEFAULT_SHAPE if self.shape.blank?
    self.type  = DEFAULT_TYPE if self.type.blank?
    self.units  = "" if self.units.blank?
    self.desc  = "" if self.desc.blank?
  end

  def shape_is_well_formed
    begin
      self.dim
    rescue BadShapeAttributeError => e
      errors.add(:shape, e.message)
    end
  end
end
