# frozen_string_literal: true

require "whats_opt/discipline"
require "whats_opt/openmdao_module"

class Analysis < ApplicationRecord
  include WhatsOpt::OpenmdaoModule
  include Ownable
  resourcify

  has_rich_text :note

  has_ancestry

  class AncestorUpdateError < StandardError; end

  has_many :disciplines, -> { includes(:variables).order(position: :asc) }, dependent: :destroy
  accepts_nested_attributes_for :disciplines,
                                reject_if: proc { |attr| attr["name"].blank? }, allow_destroy: true

  has_one :analysis_discipline, dependent: :destroy
  has_one :super_discipline, through: :analysis_discipline, source: :discipline

  has_many :meta_model_prototypes, foreign_key: :prototype_id, dependent: :destroy
  has_many :meta_models, through: :meta_model_prototypes, inverse_of: :prototype

  has_many :operations, dependent: :destroy

  has_one :openmdao_impl, class_name: "OpenmdaoAnalysisImpl", dependent: :destroy

  has_one :design_project_filing, dependent: :destroy

  scope :mine, -> { with_role(:owner, current_user) }
  scope :of_project, -> (project) { joins(:design_project_filings).where(design_project_filing: { design_project: project }) }

  after_save :refresh_connections, unless: Proc.new { self.disciplines.count < 2 }
  after_save :ensure_ancestry_for_sub_analyses
  after_save :_ensure_driver_presence
  after_save :_ensure_openmdao_impl_presence

  validates :name, presence: true, allow_blank: false
  validates :name, format: { with: /\A[a-zA-Z][_\.a-zA-Z0-9\s]*\z/, message: "%{value} is not a valid analysis name." }

  def driver
    @driver ||= disciplines.driver.take
  end

  def is_sub_analysis?
    has_parent?
  end

  def is_root_analysis?
    !has_parent?
  end

  def is_metamodel?
    disciplines.nodes.size > 0 && !disciplines.nodes.detect { |d| !d.is_metamodel? }
  end

  def is_metamodel_prototype?
    disciplines.nodes.count == 1 && disciplines.last.is_metamodel_prototype?
  end

  def uq_mode?
    !has_design_variables? && has_uncertain_input_variables?
  end

  def operated?
    operations.successful.size > 0
  end

  def variables
    @variables = Variable.of_analysis(id).active.order("variables.name ASC")
  end

  def input_variables
    @params = variables.with_role(WhatsOpt::Variable::INPUT_ROLES)
  end

  def design_variables
    @desvars = variables.with_role(WhatsOpt::Variable::DESIGN_VAR_ROLE)
  end

  def has_design_variables?
    @has_desvars = !design_variables.empty?
  end

  def uncertain_input_variables
    @uncertains ||= variables.with_role(WhatsOpt::Variable::UNCERTAIN_VAR_ROLE)
  end

  def has_uncertain_input_variables?
    @has_uncertains ||= uncertain_input_variables.size > 0
  end

  def decision_role
    uq_mode? ? WhatsOpt::Variable::UNCERTAIN_VAR_ROLE : WhatsOpt::Variable::DESIGN_VAR_ROLE
  end

  def has_decision_variables?
    has_uncertain_input_variables? || has_design_variables?
  end

  def input_variables
    @params = variables.with_role(WhatsOpt::Variable::INPUT_ROLES)
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
    variables.with_role(WhatsOpt::Variable::RESPONSE_OF_INTEREST_ROLE)
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
    input_variables.inject(0) { |s, v| s + v.dim }
  end

  def input_dim
    input_variables.inject(0) { |s, v| s + v.dim }
  end

  def plain_disciplines
    disciplines.nodes.select(&:is_plain?)
  end

  def sub_analyses
    children.joins(:analysis_discipline)
  end

  def nesting_depth
    depth = subtree.select(&:is_childless?).map(&:depth).max
    depth
  end

  def all_plain_disciplines
    @allplain ||= sub_analyses.inject(plain_disciplines) { |ary, elt| ary + elt.all_plain_disciplines }
  end

  def all_sub_analyses
    descendants.joins(:analysis_discipline)
  end

  def all_disciplines
    @alldiscs ||= sub_analyses.inject(disciplines.nodes) { |ary, elt| ary + elt.all_disciplines }
  end

  def root_analysis
    root
  end

  def has_remote_discipline?(localhost)
    @remote ||= all_plain_disciplines.detect { |d| !d.local?(localhost) }
  end

  def set_all_parameters_as_decision_variables(role = WhatsOpt::Variable::DESIGN_VAR_ROLE)
    conns = Connection.of_analysis(self).with_role(WhatsOpt::Variable::PARAMETER_ROLE)
    conns.map { |c|
      c.update_connections!(role: role)
    }
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

  def design_project
    design_project_filing&.design_project
  end

  def to_whatsopt_ui_json
    {
      id: id,
      name: name,
      project: design_project || { id: -1, name: "" },
      note: note.blank? ? "":note.to_s,

      public: public,
      operated: operated?,
      path: path.map { |a| { id: a.id, name: a.name } },
      nodes: build_nodes,
      edges: build_edges,
      inactive_edges: build_edges(active: false),
      vars: build_var_infos,
      impl: { openmdao: build_openmdao_impl,
              metamodel: { quality: build_metamodel_quality } }
    }.to_json
  end

  def to_xdsm_json
    to_xdsm.to_json
  end

  def to_xdsm(name = "root")
    xdsm = Hash[name => {
        nodes: build_nodes.map.with_index { |n, i|
          node = {
            id: n[:id],
            name: i==0 ? "_U_" : n[:name],
            type: i==0 ? "driver" : n[:type]
          }
          node[:type] = "function" if node[:type] == "analysis"  # XDSM v2
          node[:subxdsm] = n[:link][:name] if n[:type]=="group" && n[:link]
          node
        },
        edges: build_edges.map { |e|
          { from: e[:from], to: e[:to], name: e[:name] }
        }
      }
    ]
    sub_analyses.each do |submda|
      xdsm.merge!(submda.to_xdsm(submda.name))
    end
    xdsm
  end

  def build_nodes
    disciplines.by_position.map do |d|
      # node = { id: d.id.to_s, type: d.type, name: d.name, endpoint: d.endpoint }
      node = ActiveModelSerializers::SerializableResource.new(d).as_json
      # TODO: if XDSM v2 accepted migrate database to take into account XDSM v2 new types
      # mda -> group
      node[:type] = "group" if node[:type] == "mda"
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
    if is_metamodel?
      res = disciplines.inject([]) { |acc, d| acc + d.metamodel_qualification }
    end
    res
  end

  def refresh_connections(default_role_for_inputs = WhatsOpt::Variable::PARAMETER_ROLE,
                          default_role_for_outputs = WhatsOpt::Variable::RESPONSE_ROLE)
    # p "REFRESH CONNS #{self.name}"
    varouts = Variable.outs.of_analysis(id).disconnected.where.not(discipline: driver)
    # p varouts
    # check that each 'out' variables is connected
    varouts.each do |vout|
      vins = Variable.ins.of_analysis(id).where(name: vout.name)
      vins.each do |vin|
        role = WhatsOpt::Variable::STATE_VAR_ROLE
        role = default_role_for_inputs if vout.discipline.is_driver?
        role = WhatsOpt::Variable::RESPONSE_ROLE if vin.discipline.is_driver?
        existing_conn_proto = Connection.where(from_id: vout.id).take
        role = existing_conn_proto.role if existing_conn_proto
        # p "ROLE #{role}"
        # p "1 Connect #{vout.name} between #{vout.discipline.name} #{vin.discipline.name}" unless Connection.where(from_id: vout.id, to_id: vin.id).first
        Connection.where(from_id: vout.id, to_id: vin.id).first_or_create!(role: role)
      end
      if driver && vins.empty?  # connect output to driver if driver still there (analysis destroy case)
        vattrs = vout.attributes.except("id", "discipline_id")
        vattrs[:io_mode] = WhatsOpt::Variable::IN
        newvar = driver.variables.where(name: vattrs["name"], io_mode: WhatsOpt::Variable::OUT).first
        if newvar  # can occur in edge case with nested analysis while adding sub_analysis step by step
          Rails.logger.warn "Driver variable #{newvar.name} has changed io_mode OUT -> IN"
        end
        newvar = driver.variables.where(name: vattrs["name"]).first_or_create!
        newvar.update!(vattrs)
        # p "2 Connect #{vout.name} between #{vout.discipline.name} #{newvar.discipline.name}" unless Connection.where(from_id: vout.id, to_id: newvar.id).first
        Connection.where(from_id: vout.id, to_id: newvar.id).first_or_create!(role: WhatsOpt::Variable::RESPONSE_ROLE)
      end
    end

    varins = Variable.ins.of_analysis(id).disconnected.where.not(discipline: driver)
    # p varins
    # check that each in variables is connected
    varins.each do |vin|
      vouts = Variable.outs.of_analysis(id).where(name: vin.name)
      vouts.each do |vout|
        role = WhatsOpt::Variable::STATE_VAR_ROLE
        role = default_role_for_outputs if vin.discipline.is_driver?
        role = WhatsOpt::Variable::PARAMETER_ROLE if vout.discipline.is_driver?
        existing_conn_proto = Connection.where(from_id: vout.id).take
        role = existing_conn_proto.role if existing_conn_proto
        # p "ROLE #{role}"
        # p "3 Connect #{vout.name} between #{vout.discipline.name} #{vin.discipline.name}" unless Connection.where(from_id: vout.id, to_id: vin.id).first
        Connection.where(from_id: vout.id, to_id: vin.id).first_or_create!(role: role)
      end
      if driver && vouts.empty?  # connect input to driver if driver still there (analysis destroy case)
        vattrs = vin.attributes.except("id", "discipline_id")
        vattrs[:io_mode] = WhatsOpt::Variable::OUT
        newvar = driver.variables.where(name: vattrs["name"], io_mode: WhatsOpt::Variable::IN).first
        if newvar  # can occur in edge case with nested analysis while adding sub_analysis step by step
          Rails.logger.warn "Driver variable #{newvar.name} has changed io_mode IN -> OUT"
        end
        newvar = driver.variables.where(name: vattrs["name"]).first_or_create!
        newvar.update!(vattrs)
        # p "4 Connect #{vin.name} between #{newvar.discipline.name} #{vin.discipline.name}" unless Connection.where(from_id: newvar.id, to_id: vin.id).first
        Connection.where(from_id: newvar.id, to_id: vin.id).first_or_create!(role: WhatsOpt::Variable::PARAMETER_ROLE)
      end
    end

    driver.variables.disconnected.map(&:destroy!) if driver
  end

  def update!(mda_params)
    super
    if mda_params.key? :public
      descendants.each do |inner|
        inner.update_column(:public, mda_params[:public])
      end
    end
  end

  def update_design_project!(design_project_id)
    # shortcut if already referenced
    return if design_project && design_project.id == design_project_id
    if design_project_id < 0
      # remove project filing
      design_project_filing&.destroy!
    else
      dp = DesignProject.find(design_project_id)
      dpf = self.design_project_filing || self.build_design_project_filing
      dpf.update(design_project: dp)
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
            discattrs = disc.prepare_attributes_for_import!(variables, driver)
            attrs = { disciplines_attributes: [discattrs] }
            # p "ATTRS", attrs
            self.update!(attrs)
            newDisc = self.disciplines.reload.last
            if disc.is_pure_metamodel?
              newDisc.meta_model = disc.meta_model.create_copy!(self, newDisc)
            end
            if disc.has_sub_analysis?
              newDisc.sub_analysis = disc.sub_analysis.create_copy!(self)
            end
            newDisc.save!
          end
        end
      end
    end
  end

  def create_copy!(parent = nil, super_disc = nil)
    mda_copy = nil
    Analysis.transaction do  # metamodel and subanalysis are saved, rollback if problem
      mda_copy = Analysis.create!(name: name, public: public) do |copy|
        copy.parent_id = parent.id if parent
        copy.openmdao_impl = self.openmdao_impl.build_copy if self.openmdao_impl
        copy.build_design_project_filing(design_project: self.design_project) if self.design_project
      end
      mda_copy.disciplines.first.delete  # remove default driver
      self.disciplines.each do |disc|
        disc.create_copy!(mda_copy)
      end
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
          inner_driver_variable = driver.variables.find_by(name: name)
          parent.add_upstream_connection!(inner_driver_variable, super_discipline)
        end
      end
    end
  end

  def update_connections!(conn, params, down_check = true, up_check = true)
    # FIXME: do not propagate distributions for now to avoid error
    # should update distributions properly to manage distribution list should build new params
    # related to variable in sub or super-analysis
    # FIXME: Maybe sub-analysis variable edition should be disabled to avoid inconsistencies!!! 
    if (params[:distributions_attributes])
      down_check = false
      up_check = false
    end

    # propagate upward
    if up_check && should_update_analysis_ancestor?(conn)
      up_conn = Connection.of_analysis(parent)
                          .joins(:from)
                          .where(variables: { name: conn.from.name, io_mode: WhatsOpt::Variable::OUT }).take
      parent.update_connections!(up_conn, params, down_check = false, up_check) unless conn.nil?
    end

    # propagate downward
    # check connection from
    if down_check && conn.from.discipline.has_sub_analysis?
      sub_analysis = conn.from.discipline.sub_analysis
      inner_driver_var = sub_analysis.driver.variables.where(name: conn.from.name).take
      down_conn = Connection.of_analysis(sub_analysis).where("from_id = ? or to_id = ?", inner_driver_var.id, inner_driver_var.id).take
      sub_analysis.update_connections!(down_conn, params, down_check, up_check = false)
    end
    # check connection tos
    conn.from.outgoing_connections.each do |cn|
      next unless (cn.to.discipline.has_sub_analysis? and down_check) 

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
      if should_update_analysis_ancestor?(conn) && Connection.where(from: conn.from).count == 0
        parent.remove_upstream_connection!(varname, super_discipline)
      end
    end
    refresh_connections
  end

  def destroy_discipline!(disc, sub_analysis_check: true)
    Analysis.transaction do
      unless is_root?
        disc.variables.each do |v|
          Rails.logger.warn ">>> Variable #{v.name}"
          v.outgoing_connections.each do |conn|
            if should_update_analysis_ancestor?(conn) && Connection.where(from: conn.from).count <= 1
              Rails.logger.warn ">>>>>> remove Variable #{v.name} outgoing connections in upper #{parent.name}"
              parent.remove_upstream_connection!(v.name, super_discipline)
            end
          end
          conn = v.incoming_connection
          if conn
            if should_update_analysis_ancestor?(conn) && Connection.where(from: conn.from).count <= 1
              Rails.logger.warn ">>>>>> remove Variable #{v.name} incoming connection in upper #{parent.name}"
              parent.remove_upstream_connection!(v.name, super_discipline)
            end
          end
        end
      end
      disc.destroy!
      refresh_connections
    end
  end

  def should_update_analysis_ancestor?(conn)
    has_parent? && conn.driverish?
  end

  def add_upstream_connection!(inner_driver_var, discipline)
    varname = inner_driver_var.name
    io_mode = inner_driver_var.reflected_io_mode
    var_from = Variable.of_analysis(self).where(name: varname, io_mode: WhatsOpt::Variable::OUT).take
    if var_from
      if (var_from.discipline.id == discipline.id) && (io_mode == WhatsOpt::Variable::OUT)
        # already produced by sub-analysis: should not happen... but nothing to do
      else
        if var_from.discipline == driver  # case the var is linked to driver
          if io_mode == WhatsOpt::Variable::OUT  # produced by driver => now produced by sub-analysis
            var_from.update(discipline: discipline)
          else # new consumer discipline
            from_disc = driver
            to_disc = discipline
            create_connections!(from_disc, to_disc, [varname], sub_analysis_check: false)
          end
        else
          if io_mode == WhatsOpt::Variable::OUT  # variable already produced by another discipline => abort
            raise AncestorUpdateError, "Variable #{varname} already produced in parent analysis #{name}: Cannot create connection."
          else # new consumer discipline from another discipline
            from_disc = var_from.discipline
            to_disc = discipline
            create_connections!(from_disc, to_disc, [varname], sub_analysis_check: false)
          end
        end
      end
    else  # by default create connection from/to driver
      from_disc = driver
      to_disc = discipline
      from_disc, to_disc = to_disc, from_disc if inner_driver_var.is_in?
      create_connections!(from_disc, to_disc, [varname], sub_analysis_check: false)
    end
  end

  def remove_upstream_connection!(varname, discipline)
    # var = Variable.of_analysis(self).where(name: varname, discipline_id: discipline.id).take
    var = discipline.variables.find_by(name: varname)
    unless var.blank? # normally should exists but defensive programming
      if var.is_in?
        connin = var.incoming_connection
        # Rails.logger.warn ">>>>>>>>> try remove #{conn.from.name} from #{conn.from.discipline.name} ##{conn.from.id} to  ##{conn.to.discipline.name} #{conn.to.id} "
        destroy_connection!(connin, sub_analysis_check: false)
        # Rails.logger.warn "<<<<<<<<< try remove #{conn.from.name}"
      else
        var.outgoing_connections.map do |connout|
          if connout.driverish?
            # Rails.logger.warn ">>>>>>>>> try remove #{conn.from.name} from #{conn.from.discipline.name} ##{conn.from.id} to ##{conn.to.discipline.name} #{conn.to.id} "
            destroy_connection!(connout, sub_analysis_check: false)
            # Rails.logger.warn "<<<<<<<<< try remove #{conn.from.name}"
          else
            # Rails.logger.warn ">>>>>>>>> update #{conn.from.name} to be from DRIVER"
            connout.from.update(discipline: driver)
          end
        end
      end
    end
  end

  def self.build_analysis(ope_attrs, outvar_count_hint = 1)
    disc_name = "#{ope_attrs[:name].camelize}"
    name = "#{disc_name}Analysis"
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
        { name: disc_name, variables_attributes: disc_vars }
      ]
    )
  end

  def self.build_metamodel_analysis(ope, varnames = nil)
    name = "#{ope.analysis.name.camelize}MetaModel"
    metamodel_varattrs = ope.build_metamodel_varattrs(varnames)
    driver_vars = metamodel_varattrs.map do |v|
      vcopy = v.clone
      vcopy[:io_mode] = Variable.reflect_io_mode(v[:io_mode])
      vcopy
    end
    analysis_attrs= {
      name: name,
      public: ope.analysis.public,
      disciplines_attributes: [
        { name: "__DRIVER__", variables_attributes: driver_vars },
        { name: "#{ope.analysis.name.camelize}", type: WhatsOpt::Discipline::METAMODEL,
          variables_attributes: metamodel_varattrs }
    ] }
    mm_mda = Analysis.new(analysis_attrs)
    mm_mda.build_design_project_filing(design_project: ope.analysis.design_project) if ope.analysis.design_project
    mm_mda
  end

  def parameterize(parameterization)
    names = parameterization[:parameters].map { |p| p[:varname] }
    values = parameterization[:parameters].inject({}) { |acc, elt| acc[elt[:varname]] = elt[:value]; acc }
    vars = Variable.of_analysis(id).where(name: names, io_mode: WhatsOpt::Variable::OUT)
    vars.each do |v|
      v.set_init_value(values[v.name])
    end
  end

  def ensure_ancestry_for_sub_analyses
    disciplines.nodes.each do |d|
      if d.has_sub_analysis? && d.sub_analysis.parent != self
        d.sub_analysis.update(parent: self)
        d.sub_analysis.ensure_ancestry_for_sub_analyses
      end
    end
  end

  def self.create_nested_analyses(mda_attrs)
    # Rails.logger.info "################ CREATE NESTED #{mda_attrs["name"]}"
    subs = []
    # manage metamodel and sub analyses
    if  mda_attrs["disciplines_attributes"]
      mda_attrs["disciplines_attributes"].each.with_index do |disc, i|
        # when creating an analysis from params, just disable metamodel
        # and set a regular discipline instead
        disc["type"] == Discipline::DISCIPLINE if disc["type"] == Discipline::METAMODEL
        if disc["sub_analysis_attributes"]
          subs << self.create_nested_analyses(disc["sub_analysis_attributes"])
          disc.delete("sub_analysis_attributes")
        else
          subs << nil
        end
      end
    end

    # create disciplines
    # Rails.logger.info "################ BEFORE CREATE #{mda_attrs["name"]}"
    mda = Analysis.create(mda_attrs)
    # Rails.logger.info "################ AFTER CREATE #{mda_attrs["name"]}"
    # Rails.logger.info ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> #{mda.name}"
    Variable.of_analysis(mda).each do |v|
      # Rails.logger.info ">>> #{v.discipline.name}(#{v.discipline.id}) #{v.name} #{v.io_mode}"
    end
    Connection.of_analysis(mda).each do |c|
      # Rails.logger.info "CCCCCCCCCCCCCCC #{c.from.discipline.name} -> #{c.to.discipline.name}  #{c.from.name}(#{c.from.id})"
    end
    # link disciplines and sub analyses
    subs.each.with_index do |submda, i|
      if submda
        AnalysisDiscipline.build_analysis_discipline(mda.disciplines[i], submda).save!
        # Rails.logger.info "DISCIPLINE TYPE #{mda.disciplines[i].type}"
      end
    end
    # Rails.logger.info "================  EDGES of #{mda.name}"
    Connection.of_analysis(mda).each do |c|
      # Rails.logger.info "DDDDDDDDDDDDDD #{c.from.discipline.name} -> #{c.to.discipline.name}  #{c.from.name}(#{c.from.id})"
    end
    # Rails.logger.info mda.build_edges.inspect
    mda
  end

  private
    def _ensure_driver_presence
      if self.disciplines.empty?
        disciplines.create!(name: WhatsOpt::Discipline::NULL_DRIVER_NAME, position: 0)
      end
    end

    def _ensure_openmdao_impl_presence
      self.openmdao_impl ||= OpenmdaoAnalysisImpl.new
    end
end
