# frozen_string_literal: true

class OpenmdaoAnalysisImplSerializer < ActiveModel::Serializer
  attributes :parallel_group, :use_units, :optimization_driver, :packaging, :nodes, :nonlinear_solver, :linear_solver

  has_one :nonlinear_solver, class_name: "Solver"
  has_one :linear_solver, class_name: "Solver"

  def packaging
    { package_name: object.top_packagename }
  end

  def nodes 
    disciplines = object.send(:analysis).disciplines.nodes.select(&:is_plain?)
    impls = disciplines.map do |d|
      d.openmdao_impl ||= OpenmdaoDisciplineImpl.new
    end
    impls.map { |impl| ActiveModelSerializers::SerializableResource.new(impl).as_json }
  end
end
