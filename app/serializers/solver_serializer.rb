class SolverSerializer < ActiveModel::Serializer
  attributes :name, :atol, :rtol, :maxiter, :err_on_maxiter, :iprint
end