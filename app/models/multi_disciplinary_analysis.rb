class MultiDisciplinaryAnalysis < ApplicationRecord
  has_many :disciplines
  accepts_nested_attributes_for :disciplines, reject_if: proc { |attr| attr['name'].blank? }, allow_destroy: true

  validates :name, presence: true

  def get_xdsm_json
    {
      nodes: build_nodes,
      edges: build_edges,
      workflow: []
    }.to_json
  end

  def build_nodes
    @nodes ||= disciplines.map {|d| {id: "#{d.id}", type: "analysis", name: d.name} }
    return @nodes
  end

  def build_edges
    return []
  end
  
end

