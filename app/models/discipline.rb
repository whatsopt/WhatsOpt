# frozen_string_literal: true

require "resolv"
require "whats_opt/openmdao_module"
require "whats_opt/discipline"

class Discipline < ApplicationRecord
  include WhatsOpt::Discipline

  class ForbiddenRemovalError < StandardError; end

  self.inheritance_column = :disable_inheritance

  after_initialize :set_defaults, unless: :persisted?

  before_destroy :_check_allowed_destruction
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
  accepts_nested_attributes_for :endpoint, reject_if: proc { |attrs| attrs["host"].blank? || attrs["host"] == "localhost" }, allow_destroy: true
  accepts_nested_attributes_for :analysis_discipline, reject_if: :analysis_discipline_invalid?, allow_destroy: true

  validates :name, presence: true, allow_blank: false
  validates :name, format: { with: /\A[a-zA-Z][_a-zA-Z0-9]*|__DRIVER__\z/, message: "%{value} is not a valid discipline name." }
  validates :name, format: { with: /\A[^\/]*\z/, message: "%{value} is not a valid discipline name." }

  scope :driver, -> { where(type: WhatsOpt::Discipline::NULL_DRIVER) }
  scope :nodes, -> { where.not(type: WhatsOpt::Discipline::NULL_DRIVER) }
  scope :by_position, -> { order(position: :asc) }
  scope :of_analysis, -> (analysis_id) { where(analysis_id: analysis_id) }

  def journalized_attribute_names
    ["name", "type", "position"]
  end

  def analysis_discipline_invalid?(attrs)
    Rails.logger.info "FIND ANALYSIS #{Analysis.find(attrs["analysis_id"]).nil?}"
    Rails.logger.info "DISC #{attrs["discipline_id"].to_i != id}"
    invalid = (attrs["discipline_id"].to_i != id) || Analysis.find(attrs["analysis_id"]).nil?
    Rails.logger.info "INVALID #{invalid}"
    invalid
  end

  def input_variables
    @input_variables ||= variables.ins
  end

  def output_variables
    @output_variables ||= variables.outs
  end

  def input_coupling_variables
    @couplings ||= analysis.coupling_variables.map(&:name)
    input_variables.select { |v| @couplings.include?(v.name) }
  end

  def design_variables
    desvars = analysis.design_variables.map(&:name)
    input_variables.select { |v| desvars.include?(v.name) }
  end

  def output_coupling_variables
    @couplings ||= analysis.coupling_variables.map(&:name)
    output_variables.select { |v| @couplings.include?(v.name) }
  end

  def has_out_coupling?
    @couplings ||= analysis.coupling_variables.map(&:name)
    @has_out_coupling ||= output_variables.select { |v| @couplings.include?(v.name) }.empty?
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

  def is_sub_optimization?
    type == Discipline::OPTIMIZATION
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

  def is_derivable?
    variables.where(type: Variable::INTEGER_T).all.blank?
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

  def host
    has_endpoint? ? endpoint.host : "localhost"
  end

  def path
    if has_sub_analysis?
      sub_analysis.path
    else
      analysis.path
    end
  end

  def update_discipline!(params)
    if params[:position]
      insert_at(params[:position])
    end
    update!(params)
    if sub_analysis
      if type == WhatsOpt::Discipline::ANALYSIS || type == WhatsOpt::Discipline::OPTIMIZATION
        self.sub_analysis.parent = self.analysis
        self.sub_analysis.name = self.name
        self.sub_analysis.save!
      else
        # _detach_sub_analysis
        analysis_discipline.destroy
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
    self.create_sub_analysis_discipline!(new_sub_analysis)
    new_sub_analysis
  end

  def create_sub_analysis_discipline!(innermda)
    self.type = Discipline::ANALYSIS if self.type != Discipline::ANALYSIS && self.type != Discipline::OPTIMIZATION
    self.name = innermda.name
    self.save!
    ad = self.build_analysis_discipline(analysis: innermda)
    innermda.parent = self.analysis
    innermda.save!
    ad
  end

  def build_copy(mda)
    disc_copy = self.dup
    self.variables.each do |var|
      disc_copy.variables << var.build_copy
    end
    mda.disciplines << disc_copy

    if self.is_pure_metamodel?
      # Special case when metamodel: discipline has to be saved
      self.meta_model.build_copy(mda, disc_copy)
      disc_copy.save!
    end
    disc_copy.openmdao_impl = self.openmdao_impl&.build_copy

    # disc_copy.save!
    disc_copy
  end

  def metamodel_qualification
    meta_model&.qualification.nil? ? [] : meta_model.qualification
  end

  def prepare_attributes_for_import!(analysis_variables, analysis_driver, suffix = "_dup")
    # remove driver connections as new ones from new disc will take place
    analysis_driver.variables.outs.each do |driver_var|
      if self.variables.outs.where(name: driver_var.name).take
        driver_var.destroy!
      end
    end

    # new disc should not create outvars connected (hence the joins outgoing_connections)
    outvars = analysis_variables.where.not(discipline_id: analysis_driver.id)
      .where(io_mode: WhatsOpt::Variable::OUT)
      .joins(:outgoing_connections).pluck(:name).uniq
    vars = self.variables
      .where.not(io_mode: WhatsOpt::Variable::OUT)
      .or(self.variables.where.not(name: outvars))

    duplicates = self.variables.where(io_mode: WhatsOpt::Variable::OUT).where(name: outvars)
    if duplicates.size > 0
      vout = duplicates.first
      raise Connection::VariableAlreadyProducedError.new "Imported discipline produces variable #{vout.name} which is already produced by #{vout.discipline.name} discipline."
    end

    varattrs = ActiveModelSerializers::SerializableResource.new(vars,
          each_serializer: VariableSerializer).as_json
    {
      name: self.name,
      type: self.type,
      variables_attributes: varattrs  # .map {|att| att.except(:parameter_attributes, :scaling)}
    }
  end

  def is_sub_analysis_connected_by?(var)
    if has_sub_analysis?
      sub_driver = sub_analysis.driver
      !(sub_driver.variables.where(name: var.name, io_mode: var.reflected_io_mode).empty?)
    else
      false
    end
  end

  def impl
    openmdao_impl || OpenmdaoDisciplineImpl.new(discipline: self)
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
