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
  
  #has_many :disciplines, -> { order(position: :asc) }, :dependent => :destroy 
  has_many :disciplines, :dependent => :destroy 
  accepts_nested_attributes_for :disciplines, 
    reject_if: proc { |attr| attr['name'].blank? }, allow_destroy: true
      
  before_validation(on: :create) do
    _create_from_attachment if attachment_exists
  end
  validate :check_mda_import_error, on: :create, if: :attachment_exists
  validates :name, presence: true
    
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
      vars: build_var_infos
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
        connections = outputs.map(&:fullname) & inputs.map(&:fullname)
        in_connections = inputs.select{|c| connections.include?(c.fullname)}
        out_connections = outputs.select{|c| connections.include?(c.fullname)}
        unless _consistent?(in_connections, out_connections)
          raise StandardError.new("connection inconsistency in:"+in_connections.inspect+", out:"+out_connections.inspect)
        end
        @all_connections.merge(in_connections)
        unless connections.empty?
          frid = (d_from.name == WhatsOpt::Discipline::NULL_DRIVER_NAME)?"_U_":d_from.id 
          toid = (d_to.name == WhatsOpt::Discipline::NULL_DRIVER_NAME)?"_U_":d_to.id
          names = in_connections.map(&:fullname)
          edges << { from: "#{frid}", to: "#{toid}", name: names.sort.join(",") }
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

  def build_var_infos
    res = disciplines.analyses.map {|d| {d.id => {in: d.input_variables, out: d.output_variables}}}
    tree = res.inject({}) {|result, h| result.update(h)}
    tree
  end
  
  def owner
    owners = User.with_role(:owner, self)
    owners.first.login if owners
  end
  
  private
  
    def _consistent?(ins, outs)
      criteria = [:type, :units, :shape]
      ins_selection = ins.map{|var| {type: var[:type], units: var[:units], shape: var[:shape]} }
      outs_selection = ins.map{|var| {type: var[:type], units: var[:units], shape: var[:shape]} }
      ins_selection == outs_selection
    end
  
    def _get_pending_connections(vars)
      pendings = []
      vars.each do |v|
        unless @all_connections.map(&:fullname).include?(v.fullname)
          pendings << v.fullname
        end
      end
      pendings
    end      
    
    def attachment_exists
      self.attachment && self.attachment.exists?
    end
    
    def check_mda_import_error
      begin
        if self.attachment.mda_excel?
          importer = WhatsOpt::ExcelMdaImporter.new(self.attachment.path)
        elsif self.attachment.mda_cmdows?
          mda_name = File.basename(self.attachment.original_filename, '.cmdows').camelcase
          importer = WhatsOpt::CmdowsMdaImporter.new(self.attachment.path, mda_name)
        else
          self.errors.add("Bad file format")
        end
      rescue
        self.errors.add("Import error")
      end
    end
    
    def _create_from_attachment
      begin
        if self.attachment.exists?
          if self.attachment.mda_excel?
            self.name = File.basename(self.attachment.original_filename, '.xlsx').camelcase
            importer = WhatsOpt::ExcelMdaImporter.new(self.attachment.path)
          elsif self.attachment.mda_cmdows?
            self.name = File.basename(self.attachment.original_filename, '.cmdows').camelcase
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

end

