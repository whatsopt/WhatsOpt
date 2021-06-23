# frozen_string_literal: true

require "resolv"
require "whats_opt/openmdao_module"
require "whats_opt/discipline"

class Discipline < ApplicationRecord
  include WhatsOpt::Discipline
  include WhatsOpt::OpenmdaoModule

  class ForbiddenRemovalError < StandardError; end

  self.inheritance_column = :disable_inheritance

  after_initialize :set_defaults, unless: :persisted?

  before_destroy :_check_allowed_destruction
  before_destroy :_detach_sub_analysis
  before_destroy :_destroy_connections
  after_destroy :_refresh_analysis_connections

  has_many :variables, -> { includes([:parameter, :distributions, :scaling]).order("name ASC") }, dependent: :destroy
  has_one :analysis_discipline, dependent: :destroy, inverse_of: :discipline
  has_one :sub_analysis, through: :analysis_discipline, source: :analysis
  has_one :meta_model, dependent: :destroy

  belongs_to :analysis
  acts_as_list scope: :analysis, top_of_list: 0

  has_one :openmdao_impl, class_name: "OpenmdaoDisciplineImpl", dependent: :destroy
  has_one :endpoint, as: :service, dependent: :destroy

  accepts_nested_attributes_for :variables, reject_if: proc { |attrs| attrs["name"].blank? }, allow_destroy: true
  accepts_nested_attributes_for :sub_analysis, reject_if: proc { |attrs| attrs["name"].blank? }, allow_destroy: true
  accepts_nested_attributes_for :endpoint, reject_if: proc { |attrs| attrs["host"].blank? || attrs["host"]=="localhost" }, allow_destroy: true
  accepts_nested_attributes_for :analysis_discipline, reject_if: :analysis_discipline_invalid?, allow_destroy: true

  validates :name, presence: true, allow_blank: false
  validates :name, format: { with: /\A[a-zA-Z][_a-zA-Z0-9]*|__DRIVER__\z/, message: "%{value} is not a valid discipline name." }
  validates :name, format: { with: /\A[^\/]*\z/, message: "%{value} is not a valid discipline name." }

  scope :driver, -> { where(type: WhatsOpt::Discipline::NULL_DRIVER) }
  scope :nodes, -> { where.not(type: WhatsOpt::Discipline::NULL_DRIVER) }
  scope :by_position, -> { order(position: :asc) }
  scope :of_analysis, -> (analysis_id) { where(analysis_id: analysis_id) }

  def analysis_discipline_invalid?(attrs)
    Rails.logger.info "FIND ANALYSIS #{Analysis.find(attrs["analysis_id"]).nil?}"
    Rails.logger.info "DISC #{attrs["discipline_id"].to_i != id}"
    invalid = (attrs["discipline_id"].to_i != id) || Analysis.find(attrs["analysis_id"]).nil?
    Rails.logger.info "INVALID #{invalid}"
    invalid
  end

  def input_variables
    variables.ins
  end

  def output_variables
    variables.outs
  end

  def is_driver?
    type == WhatsOpt::Discipline::NULL_DRIVER
  end

  def is_pure_metamodel?
    !!meta_model
  end

  def is_metamodel_prototype?
    is_pure_metamodel? && meta_model.is_prototype?
  end

  def is_metamodel?
    !!(meta_model || (has_sub_analysis? && sub_analysis.is_metamodel?))
  end

  def is_sub_analysis?
    type == Discipline::ANALYSIS
  end

  def has_sub_analysis?
    !!sub_analysis
  end

  def is_plain?
    !has_sub_analysis?
  end

  def has_endpoint?
    !!endpoint
  end

  def local?(remote_ip)
    return true unless has_endpoint?
    endpoint_ip = Resolv.getaddress(endpoint.host)
    Rails.logger.info "Compare remote_ip=#{remote_ip} and disc endpoint=#{endpoint_ip}"
    endpoint_ip == remote_ip
  rescue
    Rails.logger.warn "Can not resolve '#{endpoint.host}' host name hosting #{name} discipline"
    true  # default to local
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
    end
    update!(params)
    if sub_analysis 
      if type != WhatsOpt::Discipline::ANALYSIS
        _detach_sub_analysis
        analysis_discipline.destroy
      elsif type == WhatsOpt::Discipline::ANALYSIS
        self.sub_analysis.parent = self.analysis
        self.sub_analysis.save!
      end
    end
  end

  def create_variables_from_sub_analysis(sub_analysis = nil)
    sub_analysis ||= analysis_discipline&.analysis
    # variables.map(&:destroy!)
    if sub_analysis
      sub_analysis.driver.output_variables.each do |outvar|
        vattr = outvar.attributes.except("name", "id", "discipline_id", "created_at", "updated_at")
        vattr["io_mode"] = WhatsOpt::Variable::IN unless is_driver?
        variables.where(name: outvar.name).first_or_create!(vattr)
      end
      sub_analysis.driver.input_variables.each do |invar|
        vattr = invar.attributes.except("name", "id", "discipline_id", "created_at", "updated_at")
        vattr["io_mode"] = WhatsOpt::Variable::OUT unless is_driver?
        variables.where(name: invar.name).first_or_create!(vattr)
      end
    end
  end

  def build_sub_analysis(mda_params)
    self.name = mda_params["name"]
    new_sub_analysis = Analysis.new(mda_params)
    AnalysisDiscipline.build_analysis_discipline(self, new_sub_analysis)
    new_sub_analysis
  end

  def create_copy!(mda)
    disc_copy = self.dup
    self.variables.each do |var|
      disc_copy.variables << var.build_copy
    end
    mda.disciplines << disc_copy
    if self.is_pure_metamodel?
      self.meta_model.create_copy!(mda, disc_copy)
    end
    if self.has_sub_analysis?
      self.sub_analysis.create_copy!(mda, disc_copy)
    end
    disc_copy.openmdao_impl = self.openmdao_impl&.build_copy

    disc_copy.save!
    disc_copy
  end

  def metamodel_qualification
    meta_model&.qualification.nil? ? [] : meta_model.qualification
  end

  def prepare_attributes_for_import!(analysis_variables, analysis_driver, suffix = "_dup")
    # remove driver connections as new ones from new disc will take place
    analysis_driver.variables.outs.each do |driver_var|
      if self.variables.outs.where(name: driver_var.name).take
        # p "Remove Driver #{driver_var.name} #{driver_var.io_mode} connection"
        driver_var.destroy!
      end
    end

    # new disc should not create outvars connected (hence the joins outgoing_connections)
    outvars = analysis_variables.where.not(discipline_id: analysis_driver.id)
      .where(io_mode: WhatsOpt::Variable::OUT)
      .joins(:outgoing_connections).pluck(:name).uniq
    # p "EXISTING OUTVARS", outvars
    # p "NEW DISC VARS", self.variables.pluck(:name).uniq
    # remove from new discipline outvars already present in the analysis
    vars = self.variables
      .where.not(io_mode: WhatsOpt::Variable::OUT)
      .or(self.variables.where.not(name: outvars))

    duplicates = self.variables.where(io_mode: WhatsOpt::Variable::OUT).where(name: outvars)
    vardupattrs = ActiveModelSerializers::SerializableResource.new(duplicates,
                                                                   each_serializer: VariableSerializer).as_json
    vardupattrs.each do |varattr|
      # p "varattr = #{varattr[:name]}"
      while outvars.include?(varattr[:name]) do
        varattr[:name] << suffix
      end
    end

    varattrs = ActiveModelSerializers::SerializableResource.new(vars,
          each_serializer: VariableSerializer).as_json + vardupattrs
    # p "VARS", vars.map(&:name)
    {
      name: self.name,
      type: self.type,
      variables_attributes: varattrs  # .map {|att| att.except(:parameter_attributes, :scaling)}
    }
  end

  private
    def set_defaults
      self.type = WhatsOpt::Discipline::DISCIPLINE if type.blank?
      if name == WhatsOpt::Discipline::NULL_DRIVER_NAME
        self.type = WhatsOpt::Discipline::NULL_DRIVER
      end
      self.openmdao_impl = OpenmdaoDisciplineImpl.new
    end

    def _destroy_connections
      conns = Connection.from_discipline(self.id) + Connection.to_discipline(self.id)
      conns.map(&:destroy!)
    end

    def _detach_sub_analysis
      if sub_analysis
        sub_analysis.parent = nil
        sub_analysis.save!
      end
    end

    def _refresh_analysis_connections
      analysis.refresh_connections
    end

    def _check_allowed_destruction
      if is_metamodel_prototype? && !self.analysis.meta_models.blank?
        mms = self.analysis.meta_models
        msg = mms.map { |mm| "##{mm.analysis.id} #{mm.analysis.name}" }.join(", ")
        raise ForbiddenRemovalError.new("Can not delete discipline metamodel '#{self.name}' as it is a prototype for metamodel in use in #{msg}")
      end
    end
end
