class MultiDisciplinaryAnalysis < ApplicationRecord
  has_many :disciplines
  accepts_nested_attributes_for :disciplines, 
    reject_if: proc { |attr| attr['name'].blank? }, allow_destroy: true

  validates :name, presence: true

  def get_xdsm_json
    {
      nodes: build_nodes,
      edges: build_edges,
      workflow: []
    }.to_json
  end

  private

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

end

