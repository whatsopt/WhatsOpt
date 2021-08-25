# frozen_string_literal: true

require "whats_opt/variable"
require "whats_opt/openmdao_variable"
require "whats_opt/thrift_variable"

class Variable < ApplicationRecord
  include WhatsOpt::Variable
  include WhatsOpt::OpenmdaoVariable
  include WhatsOpt::ThriftVariable

  DEFAULT_SHAPE = "1" # either '1', '(n,), (n, m), (n, m, p) or (n, m, p, q)'
  DEFAULT_TYPE = FLOAT_T
  DEFAULT_IOMODE = IN

  self.inheritance_column = :disable_inheritance
  belongs_to :discipline

  has_one :parameter, dependent: :destroy
  has_one :scaling, dependent: :destroy
  has_many :distributions, dependent: :destroy

  has_one  :incoming_connection, -> { includes :from }, class_name: "Connection", foreign_key: "to_id", dependent: :destroy
  has_many :outgoing_connections, -> { includes :to }, class_name: "Connection", foreign_key: "from_id", dependent: :destroy
  has_many :cases

  has_one :surrogate, dependent: :destroy

  accepts_nested_attributes_for :parameter, reject_if: proc { |attr|
                                                         attr["init"].nil? &&
                                                           attr["lower"].nil? &&
                                                           attr["upper"].nil?
                                                       }, allow_destroy: true
  accepts_nested_attributes_for :scaling, reject_if: proc { |attr|
                                                       attr["ref"].nil? &&
                                                         attr["ref0"].nil? &&
                                                         attr["res_ref"].nil?
                                                     }, allow_destroy: true

  accepts_nested_attributes_for :distributions, reject_if: proc { |attr| attr["kind"].nil? }, allow_destroy: true

  validates :name, format: { with: /\A[a-zA-Z][\-\.=:_a-zA-Z0-9]*\z/, message: "%{value} is not a valid variable name." }
  validates :name, :io_mode, :type, :shape, presence: true, allow_blank: false
  validates :name, uniqueness: { scope: [:discipline], message: -> (object, data) {
      "%{value} as a variable name should be unique for discipline #{object.discipline.name}." 
    }
  }
  validate :shape_is_well_formed

  scope :numeric, -> { where.not(type: STRING_T) }
  scope :active, -> { where(active: true) }
  scope :ins, -> { where(io_mode: IN) }
  scope :outs, -> { where(io_mode: OUT) }
  scope :uncertains, -> { joins(:distributions).distinct }
  scope :disconnected, -> { where.not(id: joins(:incoming_connection) + joins(:outgoing_connections)) }

  scope :of_analysis, ->(analysis_id) { joins(discipline: :analysis).where(analyses: { id: analysis_id }) }
  scope :of_discipline, ->(discipline_id) { where(discipline: discipline_id) }
  scope :with_role, ->(role) { joins(:outgoing_connections).where(connections: { role: role }).uniq }

  after_initialize :set_defaults, unless: :persisted?
  before_save :mark_dependents_for_removal

  def journalized_attribute_names
    [:name, :type, :shape, :desc, :units]
  end

  def is_uncertain?
    !distributions.empty?
  end

  def roles 
    outgoing_connections.map(&:role).uniq
  end

  def main_role
    conn_roles = self.roles
    if conn_roles.size > 1
      # a variable may be connected as response or as state var. Response supersedes StateVar
      conn_roles -= [WhatsOpt::Variable::STATE_VAR_ROLE]
      if conn_roles.size > 1  # should not occur then
        Rails.logger.warn "Variable #{self.name}(#{self.id}) has several roles #{self.conn_roles}. Please check and fix the database"
      end
    end
    conn_roles.first
  end

  def init_py_value
    if self.parameter&.init.blank?
      if is_in? # retrieve init value from connected uniq 'out' variable
        val = incoming_connection&.from&.init_py_value
        val || default_py_value # in case not connected
      else
        default_py_value
      end
    else
      self.parameter.init
    end
  end

  def set_init_value(val)
    val = init_py_value_from(val)
    if self.parameter
      self.parameter.update(init: val)
    else
      self.update(parameter_attributes: { init: val })
    end
  end

  def is_connected_as_input_of_interest?
    if is_in?
      WhatsOpt::Variable::INPUT_ROLES.include?(incoming_connection.role)
    else
      !outgoing_connections.where(connections: { role: WhatsOpt::Variable::INPUT_ROLES }).blank?
    end
  end

  def is_connected_as_output_of_interest?
    if is_in?
      WhatsOpt::Variable::OUTPUT_ROLES.include?(incoming_connection.role)
    else
      !outgoing_connections.where(connections: { role: WhatsOpt::Variable::OUTPUT_ROLES }).blank?
    end
  end

  def lower_py_value
    parameter&.lower.blank? ? super : parameter.lower
  end

  def upper_py_value
    parameter&.upper.blank? ? super : parameter.upper
  end

  def cstr_init_py_value
    parameter&.init.blank? ? "0.0" : parameter.init
  end

  def cstr_lower_py_value
    if main_role == WhatsOpt::Variable::CONSTRAINT_ROLE
      parameter&.lower.blank? ? super : parameter.lower
    else
      parameter&.lower.blank? ? "0.0" : parameter.lower
    end
  end

  def cstr_upper_py_value
    if main_role == WhatsOpt::Variable::CONSTRAINT_ROLE
      parameter&.upper.blank? ? super : parameter.upper
    else
      parameter&.upper.blank? ? "0.0" : parameter.upper
    end
  end

  def scaling_ref_py_value
    scaling&.ref.blank? ? super : scaling.ref
  end

  def scaling_ref0_py_value
    scaling&.ref0.blank? ? super : scaling.ref0
  end

  def scaling_res_ref_py_value
    scaling&.res_ref.blank? ? super : scaling.res_ref
  end

  def distribution_py(coord_index = -1)
    idx = [coord_index, 0].max
    if distributions
      "#{distributions[idx].kind}(#{distributions[idx].options.map(&:value).join(", ")})"
    end
  end

  def build_copy
    newvar = dup
    newvar.discipline = nil
    newvar.parameter = parameter.dup if parameter
    newvar.scaling = scaling.dup if scaling
    newvar
  end

  private
    def set_defaults
      self.io_mode = DEFAULT_IOMODE if io_mode.blank?
      self.shape = DEFAULT_SHAPE if shape.blank?
      self.type  = DEFAULT_TYPE if type.blank?
      self.units = "" if units.blank?
      self.desc  = "" if desc.blank?
    end

    def shape_is_well_formed
      dim
    rescue WhatsOpt::Variable::BadShapeAttributeError => e
      errors.add(:shape, e.message)
    end

    def name_uniqueness
      if Variable.where(discipline_id: discipline_id, name: name).count > 0
        errors.add(:name, "should be unique per discipline")
      end
    end

    def mark_dependents_for_removal
      parameter.mark_for_destruction if parameter&.nullified?
      scaling.mark_for_destruction if scaling&.nullified?
      distributions.map { |dist| dist.mark_for_destruction } if distributions.empty?
    end
end
