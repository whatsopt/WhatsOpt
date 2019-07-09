# frozen_string_literal: true

require "whats_opt/openmdao_module"
require "whats_opt/discipline"

class Discipline < ApplicationRecord
  include WhatsOpt::Discipline
  include WhatsOpt::OpenmdaoModule

  self.inheritance_column = :disable_inheritance

  has_many :variables, -> { includes(:parameter).order('name ASC') }, dependent: :destroy
  # has_many :variables, :dependent => :destroy
  has_one :analysis_discipline, dependent: :destroy
  has_one :sub_analysis, through: :analysis_discipline, source: :analysis

  belongs_to :analysis
  acts_as_list scope: :analysis, top_of_list: 0

  has_one :openmdao_impl, class_name: "OpenmdaoDisciplineImpl", dependent: :destroy

  accepts_nested_attributes_for :variables, reject_if: proc { |attr| attr["name"].blank? }, allow_destroy: true
  accepts_nested_attributes_for :sub_analysis, reject_if: proc { |attr| attr["name"].blank? }, allow_destroy: true

  validates :name, presence: true, allow_blank: false

  scope :driver, -> { where(type: WhatsOpt::Discipline::NULL_DRIVER).take }
  scope :nodes, -> { where.not(type: WhatsOpt::Discipline::NULL_DRIVER) }
  scope :by_position, -> { order(position: :asc) }

  after_initialize :set_defaults, unless: :persisted?

  def input_variables
    variables.inputs
  end

  def output_variables
    variables.outputs
  end

  def is_driver?
    type == WhatsOpt::Discipline::NULL_DRIVER
  end

  def has_sub_analysis?
    !!sub_analysis
  end

  def is_plain?
    !has_sub_analysis?
  end

  def path
    if has_sub_analysis?
      sub_analysis.path
    else
      analysis.path
    end
  end

  def update_discipline(params)
    if params[:position]
      insert_at(params[:position])
      params = params.except(:role)
    end
    update(params)
    if sub_analysis && type != WhatsOpt::Discipline::ANALYSIS
      analysis_discipline.analysis.update(parent_id: nil)
      analysis_discipline.destroy
    end
  end

  def create_variables_from_sub_analysis(sub_analysis = nil)
    sub_analysis ||= analysis_discipline&.analysis
    if sub_analysis
      sub_analysis.driver.output_variables.each do |outvar|
        next unless variables.where(name: outvar.name).empty?

        newvar = variables.build(outvar.attributes.except("id", "discipline_id", "created_at", "updated_at"))
        newvar.io_mode = WhatsOpt::Variable::IN unless is_driver?
        newvar.save!
      end
      sub_analysis.driver.input_variables.each do |invar|
        next unless variables.where(name: invar.name).empty?

        newvar = variables.build(invar.attributes.except("id", "discipline_id", "created_at", "updated_at"))
        newvar.io_mode = WhatsOpt::Variable::OUT unless is_driver?
        newvar.save!
      end
    end
  end

  def build_sub_analysis(mda_params)
    self.name = mda_params["name"]
    new_sub_analysis = Analysis.new(mda_params)
    AnalysisDiscipline.build_analysis_discipline(self, new_sub_analysis)
    new_sub_analysis
  end

  private
    def set_defaults
      self.type = WhatsOpt::Discipline::DISCIPLINE if type.blank?
      if name == WhatsOpt::Discipline::NULL_DRIVER_NAME
        self.type = WhatsOpt::Discipline::NULL_DRIVER
      end
      self.openmdao_impl = OpenmdaoDisciplineImpl.new
    end
end
