class OpenmdaoAnalysisImpl < ActiveRecord::Base

  NONLINEAR_SOLVERS = %w(NonlinearBlockGS RecklessNonlinearBlockGS NonlinearBlockJac NonlinearRunOnce NewtonSolver BroydenSolver)
  LINEAR_SOLVERS    = %w(LinearBlockGS LinearBlockJac LinearRunOnce DirectSolver PETScKrylov ScipyKrylov LinearUserDefined)

  belongs_to :analysis, dependent: :destroy
  belongs_to :nonlinear_solver, -> {where name: NONLINEAR_SOLVERS}, class_name: "Solver"
  belongs_to :linear_solver, -> {where name: LINEAR_SOLVERS}, class_name: "Solver"

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
    self.parallel_group = impl_attrs[:parallel_group] if impl_attrs.key?(:parallel_group)
    self.nonlinear_solver.update(impl_attrs[:nonlinear_solver]) if impl_attrs.key?(:nonlinear_solver)
    self.linear_solver.update(impl_attrs[:linear_solver]) if impl_attrs.key?(:linear_solver)
    if impl_attrs[:disciplines]
      # update openmdao discipline impls
    end
  end

  def to_code(solver_key, key)
    obj = self.send(solver_key).send(key)
    case obj
    when true, false
      obj ? "True":"False"
    else
      obj.to_s
    end
  end

  private 

  def _ensure_default_impl
    self.parallel_group = false if self.parallel_group.nil?
    self.nonlinear_solver ||= Solver.new(name: "NonlinearBlockGS")
    self.linear_solver ||= Solver.new(name: "ScipyKrylov")
  end

end
