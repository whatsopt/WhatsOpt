require 'whats_opt/excel_mda_importer'
require 'whats_opt/openmdao_mapping'

class MultiDisciplinaryAnalysis < ApplicationRecord

  include WhatsOpt::OpenmdaoModule
  
  has_one :attachment, :as => :container
  accepts_nested_attributes_for :attachment, allow_destroy: true
  validates_associated :attachment
  
  has_many :disciplines
  accepts_nested_attributes_for :disciplines, 
    reject_if: proc { |attr| attr['name'].blank? }, allow_destroy: true
      
  validates :name, presence: true

  before_validation(on: :create) do
    _create_from_attachment if attachment
  end
  
  def to_json
    {
      name: self.name,
      nodes: build_nodes,
      edges: build_edges,
      workflow: [],
      vars: build_var_tree
    }.to_json
  end

  def build_nodes
    return disciplines.map {|d| { id: "#{d.id}", type: "analysis", name: d.name } }
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
          edges << { from: "#{d_from.id}", to: "#{d_to.id}", name: connections.join(",") }
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
    res = disciplines.map {|d| {d.name => {in: d.input_variables, out: d.output_variables}}}
    res.inject({}) {|result, h| result.update(h)}
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
      attachment.save
      if attachment.exists?
        emi = WhatsOpt::ExcelMdaImporter.new(self.attachment.path)
        self.name = emi.get_mda_attributes[:name]
        vars = emi.get_variables_attributes
        emi.get_disciplines_attributes().each do |dattr|
          disc = self.disciplines.build(dattr)
        end
        self.disciplines.each do |d|
          d.variables.build(vars[d.name])
        end
      end
    end

end

