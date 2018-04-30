require 'whats_opt/discipline'
require 'whats_opt/excel_mda_importer'
require 'whats_opt/cmdows_mda_importer'
require 'whats_opt/openmdao_module'

class Analysis < ApplicationRecord

  include WhatsOpt::OpenmdaoModule

  resourcify
    
  has_one :attachment, :as => :container, :dependent => :destroy
  accepts_nested_attributes_for :attachment, allow_destroy: true
  validates_associated :attachment
  
  has_many :disciplines, -> { order(position: :asc) }, :dependent => :destroy 
  has_many :operations, :dependent => :destroy 
    
  accepts_nested_attributes_for :disciplines, 
    reject_if: proc { |attr| attr['name'].blank? }, allow_destroy: true
      
  before_validation(on: :create) do
    _create_from_attachment if attachment_exists
  end
  
  after_save(on: :create) do
    Connection.create_connections(self)
  end
  
    
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
 
  def objective_variables
    @objs ||= variables.with_role(WhatsOpt::Variable::OBJECTIVE_ROLE) 
  end

  def eq_constraint_variables
    @eqs ||= variables.with_role(WhatsOpt::Variable::EQ_CONSTRAINT_ROLE)  
  end

  def ineq_constraint_variables
    @ineqs ||= variables.with_role(WhatsOpt::Variable::INEQ_CONSTRAINT_ROLE)  
  end
  
  def response_variables
    @resps ||= variables.with_role(WhatsOpt::Variable::RESPONSE_ROLE) + 
      objective_variables + eq_constraint_variables + ineq_constraint_variables
  end
  
  def input_dim
    parameter_variables.inject(0){|s, v| s+v.dim}
  end
  
  def output_dim
    response_variables.inject(0){|s, v| s+v.dim}
  end
    
  def to_mda_viewer_json
    { 
      id: self.id,
      name: self.name,
      nodes: build_nodes,
      edges: build_edges,
      inactive_edges: build_edges(active: false),
      vars: build_var_infos
    }.to_json
  end
  
  def build_nodes
    return self.disciplines.map {|d| 
      { id: "#{d.id}", type: d.type , name: d.name } 
    }
  end

  def build_edges(active: true)
    edges = []
    self.disciplines.each do |d_from|
      from_id = d_from.id.to_s 
      self.disciplines.each do |d_to|
        next if d_from == d_to
        to_id = d_to.id.to_s  
        if active
          conns = Connection.between(d_from.id, d_to.id).active
        else
          conns = Connection.between(d_from.id, d_to.id).inactive
        end
        if self.attachment&.mda_cmdows?
          names = conns.map{ |c| c.from.fullname }.join(",")
        else
          names = conns.map{ |c| c.from.name }.join(",")
        end
        ids = conns.map(&:id)
        roles = conns.map {|c| c[:role]}
        unless conns.empty?
          edges << { from: from_id, to: to_id, name: names, conn_ids: ids, active: active, roles: roles }
        end
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
    owners = User.with_role(:owner, self)
    owners.take.login if owners
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

