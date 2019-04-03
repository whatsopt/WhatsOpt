class OpenmdaoAnalysisImplSerializer < ActiveModel::Serializer
  attributes :parallel_group, :nonlinear_solver, :linear_solver 

  has_one :nonlinear_solver, class_name: "Solver"
  has_one :linear_solver, class_name: "Solver"
end