# frozen_string_literal: true

class SolverSerializer < ActiveModel::Serializer
  attributes :name, :atol, :rtol, :maxiter, :err_on_non_converge, :iprint
end
