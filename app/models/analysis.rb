# frozen_string_literal: true

require "whats_opt/discipline"
require "whats_opt/excel_mda_importer"
require "whats_opt/cmdows_mda_importer"
require "whats_opt/openmdao_module"

class Analysis < ApplicationRecord

  include WhatsOpt::OpenmdaoModule
  include Ownable

  resourcify

  has_rich_text :note

  has_ancestry orphan_strategy: :rootify

  class AncestorUpdateError < StandardError
  end

  has_one :attachment, as: :container, dependent: :destroy
  accepts_nested_attributes_for :attachment, allow_destroy: true
  validates_associated :attachment

  has_many :disciplines, -> { includes(:variables).order(position: :asc) }, dependent: :destroy
  accepts_nested_attributes_for :disciplines,
                                reject_if: proc { |attr| attr["name"].blank? }, allow_destroy: true

  has_one :analysis_discipline, dependent: :destroy
  has_one :super_discipline, through: :analysis_discipline, source: :discipline

  has_many :operations, dependent: :destroy

  has_one :openmdao_impl, class_name: "OpenmdaoAnalysisImpl", dependent: :destroy

  scope :mine, ->{ with_role(:owner, current_user) }

  before_validation(on: :create) do
    _create_from_attachment if attachment_exists?
  end

  after_save :refresh_connections, unless: Proc.new { self.disciplines.count < 2 }
  after_save :_ensure_ancestry
  after_save :_ensure_driver_presence
  after_save :_ensure_openmdao_impl_presence

  before_destroy :_check_allowed_destruction

  validate :_check_mda_import_error, on: :create, if: :attachment_exists?
  validates :name, presence: true, allow_blank: false

  def driver
    @driver ||= disciplines.driver.take
  end

  def is_sub_analysis?
    has_parent?
  end

  def is_root_analysis?
    !has_parent?
  end

  def is_metamodel_analysis?
    !disciplines.nodes.detect { |d| !d.is_metamodel? }
  end

  def variables
    @variables = Variable.of_analysis(id).active.order("variables.name ASC")
  end

  def parameter_variables
    @params = variables.with_role(WhatsOpt::Variable::PARAMETER_ROLE) + design_variables
  end

  def design_variables
    @desvars = variables.with_role(WhatsOpt::Variable::DESIGN_VAR_ROLE)
  end

  def has_design_variables?
    @has_desvars = !design_variables.empty?
  end

  def min_objective_variables
    @minobjs = variables.with_role(WhatsOpt::Variable::MIN_OBJECTIVE_ROLE)
  end

  def max_objective_variables
    @maxobjs = variables.with_role(WhatsOpt::Variable::MAX_OBJECTIVE_ROLE)
  end

  def objective_variables
    @objs = variables.with_role(WhatsOpt::Variable::OBJECTIVE_ROLES)
  end

  def has_objective?
    @has_obj = !objective_variables.empty?
  end

  def eq_constraint_variables
    @eqs = variables.with_role(WhatsOpt::Variable::EQ_CONSTRAINT_ROLE)
  end

  def ineq_constraint_variables
    @ineqs = variables.with_role(WhatsOpt::Variable::INEQ_CONSTRAINT_ROLE)
  end

  def responses_of_interest
    variables.with_role(WhatsOpt::Variable::INTEREST_OUTPUT_ROLES)
  end

  def response_variables
    @resps = variables.with_role(WhatsOpt::Variable::OUTPUT_ROLES)
  end

  def response_dim
    response_variables.inject(0) { |s, v| s + v.dim }
  end

  def responses_of_interest_dim
    responses_of_interest.inject(0) { |s, v| s + v.dim }
  end

  def design_var_dim
    design_variables.inject(0) { |s, v| s + v.dim }
  end

  def parameter_dim
    parameter_variables.inject(0) { |s, v| s + v.dim }
  end

  def input_dim
    parameter_variables.inject(0) { |s, v| s + v.dim }
  end

  def plain_disciplines
    disciplines.nodes.select(&:is_plain?)
  end

  def sub_analyses
    children
  end

  def all_plain_disciplines
    @allplain ||= children.inject(plain_disciplines) { |ary, elt| ary + elt.all_plain_disciplines }
  end

  def all_sub_analyses
    descendants
  end

  def all_disciplines
    @alldiscs ||= children.inject(disciplines.nodes) { |ary, elt| ary + elt.all_disciplines }
  end

  def attachment_exists?
    attachment&.exists?
  end

  def root_analysis
    root
  end

  def has_remote_discipline?(localhost)
    @remote ||= all_plain_disciplines.detect { |d| !d.local?(localhost) }
  end

  def set_all_parameters_as_design_variables
    conns = Connection.of_analysis(self).with_role(WhatsOpt::Variable::PARAMETER_ROLE)
    conns.map { |c| c.update!(role: WhatsOpt::Variable::DESIGN_VAR_ROLE) }
  end

  def next_operation_id(opeId)
    @opeIds ||= operations.successful.pluck(:id)
    idx = @opeIds.index(opeId)
    @next ||= (idx == (@opeIds.size - 1)) ? -1 : @opeIds[idx+1]
  end

  def prev_operation_id(opeId)
    @opeIds ||= operations.successful.pluck(:id)
    idx = @opeIds.index(opeId)
    @prev ||= (idx == 0) ? -1 : @opeIds[idx-1]
  end

  def to_mda_viewer_json
    {
      id: id,
      name: name,
      note: note.blank? ? "":note.to_s,

      public: public,
      path: path.map { |a| { id: a.id, name: a.name } },
      nodes: build_nodes,
      edges: build_edges,
      inactive_edges: build_edges(active: false),
      vars: build_var_infos,
      impl: { openmdao: build_openmdao_impl,
              metamodel: { quality: build_metamodel_quality } }
    }.to_json
  end

  def build_nodes
    disciplines.by_position.map do |d|
      # node = { id: d.id.to_s, type: d.type, name: d.name, endpoint: d.endpoint }
      node = ActiveModelSerializers::SerializableResource.new(d).as_json
      # TODO: if XDSM v2 accepted migrate database to take into account XDSM v2 new types
      # mda -> group
      node[:type] = 'group' if node[:type] == 'mda'
      # not required as function and analysis are considered synonymous in XDSMjs for XDSM v2
      # node[:type] = 'function' if node[:type] == 'analysis' 
      node[:id] = node[:id].to_s
      node[:link] = { id: parent.id, name: parent.name } if d.is_driver? && has_parent?
      node[:link] = { id: d.sub_analysis.id, name: d.sub_analysis.name } if d.has_sub_analysis?
      node
    end
  end

  def build_edges(active: true)
    edges = []
    _edges = {}
    disc_ids = disciplines.map(&:id)
    disc_ids.each do |id|
      _edges.update(Hash[disc_ids.collect { |item| [[id, item], []] }])
    end
    disc_ids.each do |from_id|
      conns = Connection.joins(:from).where(variables: { discipline_id: from_id, active: active }).order("variables.name")
      conns.each do |conn|
        _edges[[from_id, conn.to.discipline.id]] << conn
      end
    end
    _edges.each do |k, conns|
      next if conns.empty?

      names = conns.map { |c| c.from.name }.join(",")
      ids = conns.map(&:id)
      roles = conns.map { |c| c[:role] }
      edges << { from: k[0].to_s, to: k[1].to_s, name: names, conn_ids: ids, active: active, roles: roles }
    end
    edges
  end

  def build_var_infos
    res = disciplines.map do |d|
      inputs = ActiveModelSerializers::SerializableResource.new(d.input_variables,
                                                                each_serializer: VariableSerializer)
      outputs = ActiveModelSerializers::SerializableResource.new(d.output_variables,
                                                                 each_serializer: VariableSerializer)
      id = d.id
      { id => { in: inputs.as_json, out: outputs.as_json } }
    end
    tree = res.inject({}) { |result, h| result.update(h) }
    tree
  end

  def build_openmdao_impl
    self.openmdao_impl ||= OpenmdaoAnalysisImpl.new
    ActiveModelSerializers::SerializableResource.new(self.openmdao_impl).as_json
  end

  def build_metamodel_quality
    res = []
    if is_metamodel_analysis?
      res = disciplines.inject([]) { |acc, d| acc + d.metamodel_qualification }
    end
    res
  end

  def refresh_connections(default_role_for_inputs = WhatsOpt::Variable::PARAMETER_ROLE,
                          default_role_for_outputs = WhatsOpt::Variable::RESPONSE_ROLE)
    # p "REFRESH CONNS #{self.name}"
    varouts = Variable.outputs.joins(discipline: :analysis).where(analyses: { id: id })
    varins = Variable.inputs.joins(discipline: :analysis).where(analyses: { id: id })
    # check that each out variables is connected
    varouts.each do |vout|
      vins = varins.where(name: vout.name)
      vins.each do |vin|
        role = WhatsOpt::Variable::STATE_VAR_ROLE
        role = default_role_for_inputs if vout.discipline.is_driver?
        role = WhatsOpt::Variable::RESPONSE_ROLE if vin.discipline.is_driver?
        existing_conn_proto = Connection.where(from_id: vout.id).take
        role = existing_conn_proto.role if existing_conn_proto
        # p "ROLE #{role}"
        # p "1 Connect #{vout.name} between #{vout.discipline.name} #{vin.discipline.name}" unless Connection.where(from_id: vout.id, to_id: vin.id).first 
        Connection.where(from_id: vout.id, to_id: vin.id).first_or_create!(role: role)
        # if Variable.where(name: vout.name, io_mode: WhatsOpt::Variable::OUT)
      end
      if driver && vins.empty?  # connect output to driver if driver still there (analysis destroy case)
        vattrs = vout.attributes.except("id")
        vattrs[:io_mode] = WhatsOpt::Variable::IN
        newvar = driver.variables.create(vattrs)
        # p "2 Connect #{vout.name} between #{vout.discipline.name} #{newvar.discipline.name}" unless Connection.where(from_id: vout.id, to_id: newvar.id).first
        Connection.where(from_id: vout.id, to_id: newvar.id).first_or_create!(role: WhatsOpt::Variable::RESPONSE_ROLE) 
      end
    end
    # check that each in variables is connected
    varins.each do |vin|
      vouts = varouts.where(name: vin.name)
      vouts.each do |vout|
        role = WhatsOpt::Variable::STATE_VAR_ROLE
        role = default_role_for_outputs if vin.discipline.is_driver?
        role = WhatsOpt::Variable::PARAMETER_ROLE if vout.discipline.is_driver?
        existing_conn_proto = Connection.where(from_id: vout.id).take
        role = existing_conn_proto.role if existing_conn_proto
        # p "3 Connect #{vout.name} between #{vout.discipline.name} #{vin.discipline.name}" unless Connection.where(from_id: vout.id, to_id: vin.id).first
        Connection.where(from_id: vout.id, to_id: vin.id).first_or_create!(role: role)
      end
      if driver && vouts.empty?  # connect input to driver if driver still there (analysis destroy case)
        vattrs = vin.attributes.except("id")
        vattrs[:io_mode] = WhatsOpt::Variable::OUT
        newvar = driver.variables.create(vattrs)
        # p "4 Connect #{vin.name} between #{newvar.discipline.name} #{vin.discipline.name}" unless Connection.where(from_id: newvar.id, to_id: vin.id).first
        Connection.where(from_id: newvar.id, to_id: vin.id).first_or_create!(role: WhatsOpt::Variable::PARAMETER_ROLE)
      end
    end
  end

  def update!(mda_params)
    super
    if mda_params.key? :public
      descendants.each do |inner|
        inner.update_column(:public, mda_params[:public])
      end
    end
  end

  def import!(fromAnalysis, discipline_ids)
    # do not import from self
    if fromAnalysis.id != id 
      Analysis.transaction do
        discipline_ids.each do |discId|
          disc = Discipline.find(discId)
          # p "***************************************** IMPORT #{disc.name}"
          # check consistency
          if disc && fromAnalysis.disciplines.where(id: discId)
            if disc.is_pure_metamodel?
              newDisc =  disc.create_copy!(self)
              newDisc.move_to_bottom
            else
              discattrs = disc.prepare_attributes_for_import!(variables, driver)
              attrs = {disciplines_attributes: [discattrs]}
              # p "ATTRS", attrs
              self.update!(attrs)
              newDisc = self.disciplines.reload.last

              if disc.has_sub_analysis?
                newDisc.sub_analysis = disc.sub_analysis.create_copy!(self)
              end
            end

            newDisc.save!
          end
        end
      end
    end
  end

  def create_copy!(parent=nil, super_disc=nil)
    mda_copy = nil
    Analysis.transaction do  # metamodel and subanalysis are saved, rollback if problem
      mda_copy = Analysis.create!(name: name, public: public) do |mda_copy|
        mda_copy.parent_id = parent.id if parent
        mda_copy.openmdao_impl = self.openmdao_impl.build_copy if self.openmdao_impl
      end
      mda_copy.disciplines.first.delete  # remove default driver
      self.disciplines.each do |disc|
        disc_copy = disc.create_copy!(mda_copy)
      end
      mda_copy.set_owner(self.owner)
      mda_copy.save!
      if super_disc
        super_disc.build_analysis_discipline(analysis: mda_copy) 
      end
    end
    mda_copy
  end

  def create_connections!(from_disc, to_disc, names, sub_analysis_check: true)
    Analysis.transaction do
      names.each do |name|
        conn = Connection.create_connection!(from_disc, to_disc, name, sub_analysis_check)
        if should_update_analysis_ancestor?(conn)
          inner_driver_variable = driver.variables.where(name: name).take
          parent.add_upstream_connection!(inner_driver_variable, super_discipline)
        end
      end
    end
  end

  def update_connections!(conn, params, down_check = true, up_check = true)
    # propagate upward
    if up_check && should_update_analysis_ancestor?(conn)
      up_conn = Connection.of_analysis(parent)
                          .joins(:from)
                          .where(variables: { name: conn.from.name, io_mode: WhatsOpt::Variable::OUT }).take
      parent.update_connections!(up_conn, params, down_check = false, up_check) unless conn.nil?
    end

    # propagate downward
    # check connection from
    if conn.from.discipline.has_sub_analysis?
      sub_analysis = conn.from.discipline.sub_analysis
      inner_driver_var = sub_analysis.driver.variables.where(name: conn.from.name).take
      down_conn = Connection.of_analysis(sub_analysis).where("from_id = ? or to_id = ?", inner_driver_var.id, inner_driver_var.id).take
      sub_analysis.update_connections!(down_conn, params, down_check, up_check = false)
    end
    # check connection tos
    conn.from.outgoing_connections.each do |cn|
      next unless cn.to.discipline.has_sub_analysis?

      sub_analysis = cn.to.discipline.sub_analysis
      inner_driver_var = sub_analysis.driver.variables
                                     .where(name: cn.from.name, io_mode: WhatsOpt::Variable::OUT).take
      down_conn = Connection.of_analysis(sub_analysis).where("from_id = ? or to_id = ?", inner_driver_var.id, inner_driver_var.id).take
      sub_analysis.update_connections!(down_conn, params, down_check, up_check = false)
    end

    conn.update_connections!(params)
  end

  def destroy_connection!(conn, sub_analysis_check: true)
    Analysis.transaction do
      varname = conn.from.name
      conn.destroy_connection!(sub_analysis_check)
      if should_update_analysis_ancestor?(conn)
        parent.remove_upstream_connection!(varname, super_discipline)
      end
    end
  end

  def should_update_analysis_ancestor?(conn)
    has_parent? && conn.driverish?
  end

  def add_upstream_connection!(inner_driver_var, discipline)
    varname = inner_driver_var.name
    var_from = Variable.of_analysis(self).where(name: varname, io_mode: WhatsOpt::Variable::OUT).take
    if var_from
      if (var_from.discipline.id == discipline.id) && (inner_driver_var.reflected_io == WhatsOpt::Variable::OUT)
        # ok var already produced by sub-analysis
      else
        if var_from.discipline.id != discipline.id # var consumed by sub-analysis
          from_disc = var_from.discipline
          to_disc = discipline
          create_connections!(from_disc, to_disc, [varname], sub_analysis_check: false)
        else
          raise AncestorUpdateError, "Variable #{varname} already used in parent analysis #{name}: Cannot create connection."
        end
      end
    else
      from_disc = driver
      to_disc = discipline
      from_disc, to_disc = to_disc, from_disc if inner_driver_var.is_in?
      create_connections!(from_disc, to_disc, [varname], sub_analysis_check: false)
    end
  end

  def remove_upstream_connection!(varname, discipline)
    var = Variable.of_analysis(self).where(name: varname, discipline_id: discipline.id).take
    if var.is_in?
      destroy_connection!(var.incoming_connection, sub_analysis_check: false)
    else
      var.outgoing_connections.map { |conn| destroy_connection!(conn, sub_analysis_check: false) }
    end
  end

  def self.build_analysis(ope_attrs, outvar_count_hint = 1)
    name = "#{ope_attrs[:name].camelize}Analysis"
    disc_vars = Variable.get_varattrs_from_caseattrs(ope_attrs[:cases], outvar_count_hint)
    driver_vars = disc_vars.map do |v|
      { name: v[:name],
        shape: v[:shape],
        io_mode: Variable.reflect_io_mode(v[:io_mode]) }
    end
    Analysis.new(
      name: name,
      disciplines_attributes: [
        { name: "__DRIVER__", variables_attributes: driver_vars },
        { name: name + "Model", variables_attributes: disc_vars }
      ]
    )
  end

  def self.build_metamodel_analysis(ope, varnames)
    name = "#{ope.analysis.name.camelize}MetaModel"
    metamodel_varattrs = ope.build_metamodel_varattrs(varnames)
    driver_vars = metamodel_varattrs.map do |v|
      { name: v[:name],
        shape: v[:shape],
        io_mode: Variable.reflect_io_mode(v[:io_mode]),
        parameter_attributes: v[:parameter_attributes]
      }
    end
    analysis_attrs= {
      name: name,
      disciplines_attributes: [
        { name: "__DRIVER__", variables_attributes: driver_vars },
        { name: "#{ope.analysis.name.camelize}Model", type: WhatsOpt::Discipline::METAMODEL,
          variables_attributes: metamodel_varattrs }
    ] }
    Analysis.new(analysis_attrs)
  end

  def parameterize(parameterization)
    names = parameterization[:parameters].map { |p| p[:varname] }
    values = parameterization[:parameters].inject({}) { |acc, elt| acc[elt[:varname]] = elt[:value]; acc }
    vars = Variable.of_analysis(id).where(name: names, io_mode: WhatsOpt::Variable::OUT)
    vars.each do |v|
      v.set_init_value(values[v.name])
    end
  end

  private
    def _check_mda_import_error
      if attachment.mda_excel?
        WhatsOpt::ExcelMdaImporter.new(attachment.path)
      elsif attachment.mda_cmdows?
        mda_name = File.basename(attachment.original_filename, ".*").camelcase
        WhatsOpt::CmdowsMdaImporter.new(attachment.path, mda_name)
      else
        errors.add(:attachment, "Bad file format")
      end
    rescue StandardError
      errors.add(:attachment, "Import error")
    end

    def _create_from_attachment
      if attachment.exists?
        if attachment.mda_excel?
          self.name = File.basename(attachment.original_filename, ".xlsx").camelcase
          importer = WhatsOpt::ExcelMdaImporter.new(attachment.path, name)
        elsif attachment.mda_cmdows?
          self.name = File.basename(attachment.original_filename, ".*").camelcase
          importer = WhatsOpt::CmdowsMdaImporter.new(attachment.path, name)
        else
          raise WhatsOpt::MdaImporter::MdaImportError, "bad format, can not be imported as an MDA"
        end
        self.name = importer.get_mda_attributes[:name]
        vars = importer.get_variables_attributes
        importer.get_disciplines_attributes.each do |dattr|
          id = dattr[:id]
          dattr.delete(:id)
          disc = disciplines.build(dattr)
          disc.variables.build(vars[id]) if vars[id]
        end
      else
        raise WhatsOpt::MdaImporter::MdaImportError, "does not exist"
      end
    rescue WhatsOpt::MdaImporter::MdaImportError => e
      errors.add(:attachment, e.message)
    end

    def _ensure_driver_presence
      if self.disciplines.empty?
        disciplines.create!(name: WhatsOpt::Discipline::NULL_DRIVER_NAME, position: 0)
      end
    end

    def _ensure_ancestry
      disciplines.nodes
                 .select { |d| d.has_sub_analysis? && d.sub_analysis.parent != self }
                 .each { |d| d.sub_analysis.update(parent_id: id) unless new_record? }
    end

    def _ensure_openmdao_impl_presence
      self.openmdao_impl ||= OpenmdaoAnalysisImpl.new
    end

    def _check_allowed_destruction
      # to do check ancestry: forbid if parent
    end
end
