# frozen_string_literal: true

require "matrix"

class MetaModel < ApplicationRecord
  belongs_to :discipline
  belongs_to :operation

  has_one :meta_model_prototype, dependent: :destroy
  has_one :prototype, through: :meta_model_prototype, source: :prototype, class_name: :Analysis
  accepts_nested_attributes_for :meta_model_prototype

  has_many :default_options, class_name: 'Option', as: :optionizable, dependent: :destroy
  accepts_nested_attributes_for :default_options, reject_if: proc { |attr| attr["name"].blank? }, allow_destroy: true 

  has_many :surrogates, dependent: :destroy

  validates :discipline, presence: true

  after_initialize :_set_defaults
  before_destroy :_destroy_related_operation

  MATRIX_FORMAT = "matrix"
  FORMATS = [MATRIX_FORMAT]

  class PredictionError < StandardError; end
  class BadKindError < StandardError; end

  def self.get_driver_from_metamodel_kind(kind)
    library, algo = get_infos_from_metamodel_kind(kind)
    "#{library}_metamodel_#{algo}"
  end

  def self.get_name_from_metamodel_kind(kind)
    library, algo = get_infos_from_metamodel_kind(kind)
    "Metamodel #{algo}"
  end

  def self.get_infos_from_metamodel_kind(kind)
    kind = kind.downcase
    if Surrogate::SURROGATES.include?(kind.upcase) && kind =~ /(\w+)_(\w+)/
      return $1, $2
    else
      raise BadKindError.new("Unknown metamodel kind #{kind}")
    end
  end

  def analysis
    discipline.analysis  # a metamodel a no existence out of analysis context
  end

  def build_surrogates
    opts = default_options.map {|o| {name: o[:name], value: o[:value]}}
    analysis.response_variables.each do |v|
      (0...v.dim).each do |index|
        surrogates.build(variable: v, coord_index: index-1, kind: default_surrogate_kind, options_attributes: opts)
      end
    end
  end

  def create_copy!(mda=nil, discipline=nil)
    mm_copy = self.dup
    mm_copy.prototype = prototype || analysis
    if discipline
      mm_copy.discipline = discipline 
      # variables = Variable.of_analysis(mm_copy.prototype).outs
      # ope_copy = self.operation.create_copy!(discipline.analysis, varnames=[], variables)
      # mm_copy.operation = ope_copy
      # ope_copy.save!
    end
    self.surrogates.each do |surr|
      var = discipline.variables.where(name: surr.variable.name).take if discipline
      surr_copy = surr.build_copy(mm_copy, var)
    end
    self.default_options.each do |opt|
      mm_copy.default_options << opt.build_copy
    end
    mm_copy
  end

  def train(force: true)
    surrogates.each do |surr|
      surr.train if force || !surr.trained?
    end
  end

  def predict(values)
    res = []
    # Convention: values in res corresponds to var names alphabetically sorted
    sorted = surrogates.sort_by { |surr| surr.variable.name }
    names = sorted.map { |surr| surr.variable.name }
    Rails.logger.info "Predict with surrogates of : #{names}"
    sorted.each do |surr|
      yvals = surr.predict(values)
      if res.empty?
        res = yvals.map { |y| [y] }
      else
        yvals.each_with_index do |y, i|
          res[i] << y
        end
      end
    end
    res
  rescue => e
    raise PredictionError.new("Cannot make prediction for #{values}, error: #{e}")
  end

  def training_input_names
    @training_input_names ||= operation.input_cases.map { |c| c.label }
  end

  def training_input_uncertainties
    @distributions ||= operation.input_cases.map { |c| c.variable.distribution }.compact
    @uncertainties ||= @distributions.map do |d| 
      {name: d.kind, kwargs: d.options.inject({}) {|acc, opt| acc.update([[opt.name, opt.value]].to_h) }} 
    end
  end

  def training_input_values
    @training_inputs ||= Matrix.columns(operation.input_cases.sort_by { |c| c.label }.map(&:values)).to_a
  end

  def training_output_values(varname, coord_index)
    @training_outputs = operation.output_cases
                          .detect {|c| c.variable.name == varname && c.coord_index == coord_index}.values
  end

  def qualification
    surrogates.map(&:qualify)
  end

private
  def _set_defaults
    self.default_surrogate_kind = Surrogate::SMT_KRIGING if self.default_surrogate_kind.blank?
  end

  def _destroy_related_operation
    self.operation.destroy! if operation
  end
end
