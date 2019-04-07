class OpenmdaoAnalysisImplSerializer < ActiveModel::Serializer
  attributes :components, :nonlinear_solver, :linear_solver 

  has_one :nonlinear_solver, class_name: "Solver"
  has_one :linear_solver, class_name: "Solver"

  def components
    disciplines = object.send(:analysis).disciplines.nodes.select(&:is_plain?)
    impls = disciplines.map do |d|
      d.openmdao_impl ||= OpenmdaoDisciplineImpl.new
    end
    {
      parallel_group: object.send(:parallel_group),
      nodes: impls.map{|impl| ActiveModelSerializers::SerializableResource.new(impl).as_json }
    }
  end
end