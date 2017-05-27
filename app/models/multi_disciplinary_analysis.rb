require 'whats_opt/excel_mda_importer'

class MultiDisciplinaryAnalysis < ApplicationRecord

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
  
  def get_xdsm_json
    {
      nodes: build_nodes,
      edges: build_edges,
      workflow: []
    }.to_json
  end

  def build_nodes
    nodes = disciplines.map {|d| { id: "#{d.id}", 
                                   type: "analysis", 
                                   name: d.name } }
    return nodes
  end

  def build_edges
    edges = []
    all_connections = Set.new

    # connections
    disciplines.each do |d_from|
      outputs = d_from.output_variables 
      disciplines.each do |d_to|
        next if d_to == d_from
        inputs = d_to.input_variables
        connections = outputs.map(&:name) & inputs.map(&:name)
        all_connections.merge(connections)
        unless connections.empty?
          edges << { from: "#{d_from.id}", to: "#{d_to.id}", 
                     name: connections.join(",") }
        end
      end
    end

    # pendings
    disciplines.each do |d|
      pendings = []
      d.input_variables.each do |v|
        unless all_connections.include?(v.name)
          pendings << v.name
        end
      end
      unless pendings.empty?
        edges << { from: "_U_", to: "#{d.id}", 
                   name: pendings.join(",") }
      end

      pendings = [] 
      d.output_variables.each do |v|
        unless all_connections.include?(v.name)
          pendings << v.name
        end
      end 
      unless pendings.empty?
        edges << { from: "#{d.id}", to: "_U_", 
                   name: pendings.join(",") }
      end        
    end    
    edges
  end
  
  private

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

