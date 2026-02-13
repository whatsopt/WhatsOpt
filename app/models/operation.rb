# frozen_string_literal: false

require "whats_opt/sqlite_case_importer"


class Operation < ApplicationRecord
  CAT_RUNONCE = "analysis"
  CAT_OPTIMIZATION = "optimization"
  CAT_EGMDO = "egmdo"
  CAT_DOE = "doe"
  CAT_EGDOE = "egdoe"
  CAT_SENSITIVITY_DOE = "sensitivity_doe"
  CAT_SENSITIVITY = "sensitivity_analysis"
  CATEGORIES = [CAT_RUNONCE, CAT_OPTIMIZATION,
                CAT_EGDOE, CAT_EGMDO,
                CAT_DOE, CAT_SENSITIVITY_DOE,
                CAT_SENSITIVITY].freeze

  SUCCESS_STATUSES = %w[DONE ASSUME_DONE DONE_OFFLINE].freeze

  class ForbiddenRemovalError < StandardError; end

  belongs_to :analysis
  has_many :options, as: :optionizable, dependent: :delete_all
  accepts_nested_attributes_for :options, reject_if: proc { |attr| attr["name"].blank? }, allow_destroy: true

  # when optimization / doe
  has_many :cases, -> { joins(:variable).order("name ASC") }, dependent: :delete_all
  # when derived from doe
  has_many :derived_operations, class_name: "Operation", foreign_key: "base_operation_id", inverse_of: :base_operation
  belongs_to :base_operation, class_name: "Operation", foreign_key: "base_operation_id", inverse_of: :derived_operations

  before_destroy :_check_allowed_destruction

  validates :name, presence: true, allow_blank: false
  validates :driver, presence: true, allow_blank: false
  validate :success_flags_consistent_with_cases

  scope :successful, ->() { where(status: SUCCESS_STATUSES) }
  scope :final, ->() { where.not(id: pluck(:base_operation_id).compact) }
  scope :done, ->(analysis) { where(analysis: analysis).successful }
  scope :newest, ->() { order(updated_at: :desc) }

  serialize :success, type: Array

  def success_flags_consistent_with_cases
    if (cases.blank? && !success.blank?) || (!cases.blank? && (cases[0].values.size != success.size))
      errors.add(:success, "success size (#{success.size}) can not be different from cases values size (#{cases.blank? ? 0 : cases[0].values.size})")
    end
  end

  def self.build_operation(mda, ope_attrs)
    operation = mda.operations.build(ope_attrs.except(:cases))
    operation.name = ope_attrs[:driver] unless ope_attrs[:name]
    operation._build_cases(ope_attrs[:cases]) if ope_attrs[:cases]
    opecat = operation.category
    case opecat
    when CAT_DOE, CAT_SENSITIVITY_DOE, CAT_OPTIMIZATION
      operation.status = "DONE_OFFLINE"
      operation.build_derived_operations
    else
      operation.status = "DONE_OFFLINE"
    end
    operation
  end

  def build_derived_operations
    case self.category
    when CAT_SENSITIVITY_DOE
      if self.driver =~ /(\w+)_doe_(\w+)/
        library = $1
        algo = $2
        derived = self.derived_operations.build(name: "Sensitivity #{algo}",
                                                driver: "#{library}_sensitivity_#{algo}",
                                                analysis_id: self.analysis_id)
        derived.status = "ASSUME_DONE"
      else
        Rails.logger.warn('Unknown sensitivity method for sensitivity DOE driver #{self.driver}')
      end
    end
  end

  def to_plotter_json
    adapter = ActiveModelSerializers::SerializableResource.new(self)
    adapter.to_json
  end

  def success?
    SUCCESS_STATUSES.include?(status)
  end

  def sensitivity_analysis?
    self.category == CAT_SENSITIVITY
  end

  def doe?
    self.category == CAT_DOE
  end

  def category
    @category ||=
      case driver
      when "runonce"
        CAT_RUNONCE
      when /egmdo/
        CAT_EGMDO
      when /egdoe/
        CAT_EGDOE
      when /optimizer/, /slsqp/, /scipy/, /pyoptsparse/
        CAT_OPTIMIZATION
      when /_doe_morris/, /doe_sobol/
        CAT_SENSITIVITY_DOE
      when /_sensitivity_morris/, /_sensitivity_sobol/, /_sensitivity_pce/
        CAT_SENSITIVITY
      when /doe/, /lhs/
        CAT_DOE
      else
        if !analysis.objective_variables.empty?
          CAT_OPTIMIZATION
        else
          CAT_DOE
        end
      end
   end

  def nb_of_points
    cases[0]&.nb_of_points || 0
  end

  def option_hash
    options.to_h { |h| [h["name"].to_sym, h["value"]] }
  end

  def update_operation(ope_attrs)
    ope_attrs[:options_attributes]&.each do |opt|
      opt[:value] = opt[:value].to_s
    end
    update(ope_attrs.except(:cases))
    if ope_attrs[:cases]
      _update_cases(ope_attrs[:cases])
      unless self.valid?
        update(status: "FAILED")
      end
    end
  end

  def _ope_cases
    @ope_cases ||= base_operation ? base_operation._ope_cases : cases.sort_by { |c| c.var_label }
  end

  def input_cases
    if analysis.has_uncertain_input_variables?
      @input_cases ||= _ope_cases.select { |c| c.variable.is_uncertain? && c.variable.is_connected_as_input_of_interest? }
    else
      @input_cases ||= _ope_cases.select { |c| c.variable.is_connected_as_input_of_interest? }
    end
  end

  def output_cases
    _ope_cases.select { |c| c.variable.is_connected_as_output_of_interest? }
  end

  def sorted_cases
    input_cases + output_cases
  end

  # suppose analysis is already saved in database
  def create_copy!(dest_analysis, varnames = [], prototypes_variables = Variable.none)
    ope_copy = dest_analysis.operations.build(self.attributes.except("id"))
    self.cases.each_with_index do |c|
      vname = c.variable.name
      if varnames.empty? || varnames.include?(vname)
        dest_variable = prototypes_variables.where(name: vname).take unless prototypes_variables.blank?
        c_copy = c.build_copy(ope_copy, dest_variable)
        ope_copy.cases << c_copy
      end
    end
    ope_copy.success = [] if ope_copy.cases.blank?
    if base_operation
      ope_copy.base_operation = base_operation.create_copy!(dest_analysis, varnames, prototypes_variables)
    end
    ope_copy.save!
    ope_copy
  end

  def _build_cases(case_attrs)
    var = {}
    case_attrs.each do |c|
      vname = c[:varname]
      var[vname] ||= Variable.where(name: vname, io_mode: WhatsOpt::Variable::OUT)
                             .joins(discipline: :analysis)
                             .where(analyses: { id: analysis.id })
                             .take
      if var[vname]
        cases.build(variable_id: var[vname].id, coord_index: c[:coord_index], values: c[:values])
      else
        Rails.logger.warn "Variable '{vname}' unknown related cases data are ignored."
      end
    end
  end

  def _update_cases(case_attrs)
    cases.map(&:destroy)
    cases.reload
    _build_cases(case_attrs)
  end

  def _check_allowed_destruction
    unless self.derived_operations.empty?
      msg = self.derived_operations.map(&:name).join(", ")
      raise ForbiddenRemovalError.new("Can not delete operation '#{self.name}' as another operation depends on it: #{msg} (to be deleted first)")
    end
  end
end
