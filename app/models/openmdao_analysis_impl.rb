# frozen_string_literal: true

class OpenmdaoAnalysisImpl < ActiveRecord::Base
  NONLINEAR_SOLVERS = %w[NonlinearBlockGS RecklessNonlinearBlockGS NonlinearBlockJac NonlinearRunOnce NewtonSolver BroydenSolver].freeze
  LINEAR_SOLVERS    = %w[LinearBlockGS LinearBlockJac LinearRunOnce DirectSolver PETScKrylov ScipyKrylov LinearUserDefined].freeze

  belongs_to :analysis
  belongs_to :nonlinear_solver, -> { where name: NONLINEAR_SOLVERS }, class_name: "Solver"
  belongs_to :linear_solver, -> { where name: LINEAR_SOLVERS }, class_name: "Solver"

  before_destroy :delete_related_solvers!

  after_initialize :_ensure_default_impl

  def delete_related_solvers!
    OpenmdaoAnalysisImpl.transaction do
      ref_count = OpenmdaoAnalysisImpl.where(nonlinear_solver_id: nonlinear_solver.id).count
      Solver.find(nonlinear_solver.id)&.delete if ref_count == 1
      ref_count = OpenmdaoAnalysisImpl.where(linear_solver_id: linear_solver.id).count
      Solver.find(linear_solver.id)&.delete if ref_count == 1
    end
  end

  def update_impl(impl_attrs)
    nonlinear_solver.update(impl_attrs[:nonlinear_solver]) if impl_attrs.key?(:nonlinear_solver)
    linear_solver.update(impl_attrs[:linear_solver]) if impl_attrs.key?(:linear_solver)
    if impl_attrs[:components]
      parallel = impl_attrs[:components][:parallel_group]
      self.parallel_group = parallel unless parallel.nil?
      use_units = impl_attrs[:components][:use_units]
      self.use_units = use_units unless use_units.nil?
      # update openmdao discipline impls
      impl_attrs[:components][:nodes]&.each do |dattr|
        OpenmdaoDisciplineImpl.where(discipline_id: dattr[:discipline_id]).update(dattr.except(:discipline_id))
      end
    end
  end

  def to_code(solver_key, key)
    obj = send(solver_key).send(key)
    case obj
    when true, false
      obj ? "True" : "False"
    else
      obj.to_s
    end
  end

  def build_copy
    oimpl_copy = self.dup
    oimpl_copy.analysis_id = nil
    oimpl_copy.nonlinear_solver = self.nonlinear_solver.build_copy
    oimpl_copy.linear_solver = self.linear_solver.build_copy
    oimpl_copy
  end

  private
    def _ensure_default_impl
      self.parallel_group = false if parallel_group.nil?
      self.nonlinear_solver ||= Solver.new(name: "NonlinearBlockGS")
      self.linear_solver ||= Solver.new(name: "ScipyKrylov")
      self.use_units = false if use_units.nil?
    end
end
