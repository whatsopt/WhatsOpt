require 'whats_opt/discipline'
require 'whats_opt/excel_mda_importer'
require 'whats_opt/cmdows_mda_importer'
require 'whats_opt/openmdao_mapping'

class MultiDisciplinaryAnalysis < ApplicationRecord

  include WhatsOpt::OpenmdaoModule

  resourcify
    
  has_one :attachment, :as => :container, :dependent => :destroy
  accepts_nested_attributes_for :attachment, allow_destroy: true
  validates_associated :attachment
  
  has_many :disciplines, :dependent => :destroy
  accepts_nested_attributes_for :disciplines, 
    reject_if: proc { |attr| attr['name'].blank? }, allow_destroy: true
      
  validates :name, presence: true

  before_validation(on: :create) do
    _create_from_attachment if attachment
  end
    
  def driver
    self.disciplines.driver&.first
  end
  
  def design_variables
    return self.driver.output_variables if driver
    []
  end

  def optimization_variables
    return self.driver.input_variables if driver
    []
  end  
  
  def objective_variables
    return self.driver.input_variables.objectives if driver
    []
  end

  def constraint_variables
    self.driver.input_variables.constraints if driver
    []
  end
  
  def to_xdsm_json
    { 
      id: self.id,
      name: self.name,
      nodes: build_nodes,
      edges: build_edges,
      workflow: [],
      vars: build_var_tree
    }.to_json
    end

  def build_nodes
    return self.disciplines.analyses.map {|d| 
      t = case d.name.downcase 
          when /function/
            "function"
          when /optimizer/
            "optimization"
          else
            "analysis"
          end 
      { id: "#{d.id}", type:t , name: d.name } 
    }
  end

  def build_edges
    edges = []
    @all_connections = Set.new

    # connections
    disciplines.each do |d_from|
      outputs = d_from.output_variables 
      disciplines.each do |d_to|
        next if d_to == d_from
        inputs = d_to.input_variables
        connections = outputs.map(&:name) & inputs.map(&:name)
        @all_connections.merge(connections)
        unless connections.empty?
          frid = (d_from.name == WhatsOpt::Discipline::DRIVER_NAME)?"_U_":d_from.id 
          toid = (d_to.name == WhatsOpt::Discipline::DRIVER_NAME)?"_U_":d_to.id
          edges << { from: "#{frid}", to: "#{toid}", name: connections.join(",") }
        end
      end
    end

    # pendings
    disciplines.each do |d|
      in_pendings = _get_pending_connections(d.input_variables)
      unless in_pendings.empty?
        edges << { from: "_U_", to: "#{d.id}", name: in_pendings.join(",") }
      end

      out_pendings = _get_pending_connections(d.output_variables)
      unless out_pendings.empty?
        edges << { from: "#{d.id}", to: "_U_", name: out_pendings.join(",") }
      end        
    end   
    edges
  end

  def build_var_tree
    res = disciplines.analyses.map {|d| {d.name => {in: d.input_variables, out: d.output_variables}}}
    res.inject({}) {|result, h| result.update(h)}
  end
  
  def owner
    owners = User.with_role(:owner, self)
    owners.first.login if owners
  end
  
  private
  
    def _get_pending_connections(vars)
      pendings = []
      vars.each do |v|
        unless @all_connections.include?(v.name)
          pendings << v.name
        end
      end
      pendings
    end      

    def _create_from_attachment
      if self.attachment.exists?
        if self.attachment.mda_excel?
          emi = WhatsOpt::ExcelMdaImporter.new(self.attachment.path)
        elsif self.attachment.mda_cmdows?
          emi = WhatsOpt::CmdowsMdaImporter.new(self.attachment.path)
        else
          raise StandardError.new
        end
        self.name = emi.get_mda_attributes[:name]
        vars = emi.get_variables_attributes
        #self.disciplines.build({ name: WhatsOpt::ExcelMdaImporter::CONTROL_NAME })
        emi.get_disciplines_attributes().each do |dattr|
          disc = self.disciplines.build(dattr)
        end
        self.disciplines.each do |d|
          d.variables.build(vars[d.name]) if vars[d.name]
        end
      end
    end

end

