require 'whats_opt/discipline'
require 'whats_opt/excel_mda_importer'
require 'whats_opt/cmdows_mda_importer'
require 'whats_opt/openmdao_module'

class Analysis < ApplicationRecord

  include WhatsOpt::OpenmdaoModule

  resourcify
  
  has_ancestry
  
  class AncestorUpdateError < StandardError
  end 
  
  has_one :attachment, :as => :container, :dependent => :destroy
  accepts_nested_attributes_for :attachment, allow_destroy: true
  validates_associated :attachment
  
  has_many :disciplines, -> { includes(:variables).order(position: :asc) }, :dependent => :destroy
  has_one :analysis_discipline, :dependent => :destroy
  has_one :super_discipline, through: :analysis_discipline, source: :discipline

  has_many :operations, :dependent => :destroy 
    
  accepts_nested_attributes_for :disciplines, 
    reject_if: proc { |attr| attr['name'].blank? }, allow_destroy: true
      
  before_validation(on: :create) do
    _create_from_attachment if attachment_exists
  end
    
  after_save :refresh_connections
  after_save :_ensure_driver_presence
  
  validate :check_mda_import_error, on: :create, if: :attachment_exists
  validates :name, presence: true, allow_blank: false
  
  def driver
    self.disciplines.driver&.take
  end

  def variables
    @variables ||= Variable.of_analysis(id).active
  end
    
  def parameter_variables
    @params ||= variables.with_role(WhatsOpt::Variable::PARAMETER_ROLE) + design_variables
  end
 
  def design_variables
    @desvars ||= variables.with_role(WhatsOpt::Variable::DESIGN_VAR_ROLE)
  end
 
  def min_objective_variables
    @minobjs = variables.with_role(WhatsOpt::Variable::MIN_OBJECTIVE_ROLE)
  end
  
  def max_objective_variables
    @maxobjs = variables.with_role(WhatsOpt::Variable::MAX_OBJECTIVE_ROLE) 
  end

  def eq_constraint_variables
    @eqs ||= variables.with_role(WhatsOpt::Variable::EQ_CONSTRAINT_ROLE)  
  end

  def ineq_constraint_variables
    @ineqs ||= variables.with_role(WhatsOpt::Variable::INEQ_CONSTRAINT_ROLE)  
  end
  
  def response_variables
    @resps ||= variables.with_role(WhatsOpt::Variable::RESPONSE_ROLE) + 
      min_objective_variables + max_objective_variables + eq_constraint_variables + ineq_constraint_variables
  end
  
  def response_dim
    response_variables.inject(0){|s, v| s+v.dim}
  end
  
  def design_var_dim
    design_variables.inject(0){|s, v| s+v.dim}
  end
  
  def parameter_dim
    parameter_variables.inject(0){|s, v| s+v.dim}
  end
  
  def input_dim
    parameter_variables.inject(0){|s, v| s+v.dim}
  end
      
  def to_mda_viewer_json
    { 
      id: self.id,
      name: self.name,
      public: self.public,
      nodes: build_nodes,
      edges: build_edges,
      inactive_edges: build_edges(active: false),
      vars: build_var_infos
    }.to_json
  end
  
  def build_nodes
    return self.disciplines.by_position.map do |d| 
      node = { id: "#{d.id}", type: d.type, name: d.name }
      node.merge!(link: {id: self.parent.id, name: self.parent.name}) if (d.is_driver? && self.parent)
      node.merge!(link: {id: d.sub_analysis.id, name: d.sub_analysis.name}) if d.sub_analysis
      node 
    end
  end

  def build_edges(active: true)
    edges = []
    _edges = {}
    disc_ids = self.disciplines.map(&:id)
    disc_ids.each do |id|
      _edges.update(Hash[disc_ids.collect { |item| [[id, item], []] } ])
    end
    disc_ids.each do |from_id|
      if active
        conns = Connection.where(variables: {discipline_id: from_id}).order('variables.name').active
      else
        conns = Connection.where(variables: {discipline_id: from_id}).order('variables.name').inactive
      end
      conns.each do |conn|
        _edges[[from_id, conn.to.discipline.id]] << conn
      end    
    end
    _edges.each do |k, conns|
      unless conns.empty?
        names = conns.map{ |c| c.from.name }.join(",")
        ids = conns.map(&:id)
        roles = conns.map {|c| c[:role]}
        edges << {from: k[0].to_s, to: k[1].to_s, name: names, conn_ids: ids, active: active, roles: roles}
      end
    end
    edges
  end
  
  def build_var_infos
    res = disciplines.map {|d|
      inputs = ActiveModelSerializers::SerializableResource.new(d.input_variables, 
        each_serializer: VariableSerializer)
      outputs = ActiveModelSerializers::SerializableResource.new(d.output_variables,
        each_serializer: VariableSerializer)
      id = d.id
      {id => {in: inputs.as_json, out: outputs.as_json}}
    }
    tree = res.inject({}) {|result, h| result.update(h)}
    tree
  end
  
  def owner
    owners = User.with_role_for_instance(:owner, self)
    owners.take&.login
  end
  
  def refresh_connections
    varouts = Variable.outputs.joins(discipline: :analysis).where(analyses: {id: self.id})
    varins = Variable.inputs.joins(discipline: :analysis).where(analyses: {id: self.id})
    varouts.each do |vout|
      vins = varins.where(name: vout.name)
      vins.each do |vin|
        role = WhatsOpt::Variable::STATE_VAR_ROLE
        if vout.discipline.is_driver?
          role = WhatsOpt::Variable::PARAMETER_ROLE
        end
        if vin.discipline.is_driver?
          role = WhatsOpt::Variable::RESPONSE_ROLE
        end
        Connection.where(from_id: vout.id, to_id: vin.id).first_or_create!(role: role)  
      end
    end
  end
  
  def create_connections!(from_disc, to_disc, names, sub_analysis_check=true)
    Analysis.transaction do
      names.each do |name|
        conn = Connection.create_connection!(from_disc, to_disc, name, sub_analysis_check)
        if self.should_update_analysis_ancestor?(conn)
          inner_driver_variable = self.driver.variables.where(name: name).take
          self.parent.add_upstream_connection!(inner_driver_variable, self.super_discipline)
        end
      end
    end 
  end
  
  def destroy_connection!(conn, sub_analysis_check=true)
    Analysis.transaction do
      varname = conn.from.name
      conn.destroy_connection!(sub_analysis_check)
      if should_update_analysis_ancestor?(conn)
        self.parent.remove_upstream_connection!(varname, self.super_discipline)
      end
    end
  end
  
  def should_update_analysis_ancestor?(conn)
    self.has_parent? and conn.driverish?
  end
    
  def add_upstream_connection!(inner_driver_var, discipline)
    varname = inner_driver_var.name
    var_from = Variable.of_analysis(self).where(name: varname, io_mode: WhatsOpt::Variable::OUT).take    
    if var_from
      if var_from.discipline.id == discipline.id and inner_driver_var.reflected_io==WhatsOpt::Variable::OUT
        #ok var already produced by sub-analysis
      else
        if var_from.discipline.id != discipline.id # var consumed by sub-analysis
          from_disc = var_from.discipline
          to_disc = discipline
          self.create_connections!(from_disc, to_disc, [varname], sub_analysis_check=false) 
        else 
          raise AncestorUpdateError.new("Variable #{varname} already used in parent analysis #{self.name}: Cannot create connection.") 
        end
      end
    else
      from_disc = self.driver
      to_disc = discipline
      from_disc, to_disc = to_disc, from_disc if inner_driver_var.is_in?
      self.create_connections!(from_disc, to_disc, [varname], sub_analysis_check=false) 
    end
  end
  
  def remove_upstream_connection!(varname, discipline)
    var = Variable.of_analysis(self).where(name: varname, discipline_id: discipline.id).take    
    if var.is_in?
      self.destroy_connection!(var.incoming_connection, sub_analysis_check=false)
    else
      var.outgoing_connections.map{|conn| self.destroy_connection!(conn, sub_analysis_check=false)}
    end
  end
  
  private
  
    def attachment_exists
      self.attachment && self.attachment.exists?
    end
    
    def check_mda_import_error
      begin
        if self.attachment.mda_excel?
          importer = WhatsOpt::ExcelMdaImporter.new(self.attachment.path)
        elsif self.attachment.mda_cmdows?
          mda_name = File.basename(self.attachment.original_filename, '.*').camelcase
          importer = WhatsOpt::CmdowsMdaImporter.new(self.attachment.path, mda_name)
        else
          self.errors.add(:attachment, "Bad file format")
        end
      rescue
        self.errors.add(:attachment, "Import error")
      end
    end
    
    def _create_from_attachment
      begin
        if self.attachment.exists?
          if self.attachment.mda_excel?
            self.name = File.basename(self.attachment.original_filename, '.xlsx').camelcase
            importer = WhatsOpt::ExcelMdaImporter.new(self.attachment.path, self.name)
          elsif self.attachment.mda_cmdows?
            self.name = File.basename(self.attachment.original_filename, '.*').camelcase
            importer = WhatsOpt::CmdowsMdaImporter.new(self.attachment.path, self.name)
          else
            raise WhatsOpt::MdaImporter::MdaImportError.new("bad format, can not be imported as an MDA")
          end
          self.name = importer.get_mda_attributes[:name]
          vars = importer.get_variables_attributes
          importer.get_disciplines_attributes().each do |dattr|
            id = dattr[:id]
            dattr.delete(:id)
            disc = self.disciplines.build(dattr)
            disc.variables.build(vars[id]) if vars[id]
          end
        else
          raise WhatsOpt::MdaImporter::MdaImportError.new("does not exist")
        end
      rescue WhatsOpt::MdaImporter::MdaImportError => e
        self.errors.add(:attachment, e.message)
      end
    end

    def _ensure_driver_presence
      if self.valid? and self.disciplines.where(name: WhatsOpt::Discipline::NULL_DRIVER_NAME).empty?
        self.disciplines.create!(name: WhatsOpt::Discipline::NULL_DRIVER_NAME, position: 0)
      end
    end
    
end

