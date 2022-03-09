# frozen_string_literal: true

class OpenmdaoAnalysisImpl < ActiveRecord::Base
  NONLINEAR_SOLVERS = %w[NonlinearBlockGS RecklessNonlinearBlockGS NonlinearBlockJac NonlinearRunOnce NewtonSolver BroydenSolver].freeze
  LINEAR_SOLVERS    = %w[LinearBlockGS LinearBlockJac LinearRunOnce DirectSolver PETScKrylov ScipyKrylov LinearUserDefined].freeze

  belongs_to :analysis
  belongs_to :nonlinear_solver, -> { where name: NONLINEAR_SOLVERS }, class_name: "Solver"
  belongs_to :linear_solver, -> { where name: LINEAR_SOLVERS }, class_name: "Solver"

  before_destroy :delete_related_solvers!

  after_initialize :_ensure_default_impl

  validates :package_name, presence: true
  validates :package_name, format: { with: /\A[a-z]+[_a-z0-9]*\z/, message: "should follow PEP8 recommendation for Python package names"}
  NULL_PACKAGE_NAME = "pkg_place_holder"

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
    parallel = impl_attrs[:parallel_group]
    self.parallel_group = parallel unless parallel.nil?
    use_units = impl_attrs[:use_units]
    self.use_units = use_units unless use_units.nil?
    optimization_driver = impl_attrs[:optimization_driver]
    self.optimization_driver = optimization_driver unless optimization_driver.nil?
    packaging = impl_attrs[:packaging]
    self.update(package_name: packaging[:package_name]) unless packaging.nil?
    impl_attrs[:nodes]&.each do |dattr|
      OpenmdaoDisciplineImpl.where(discipline_id: dattr[:discipline_id]).update(dattr.except(:discipline_id))
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

  def egmdo_support_derivatives?
    analysis.all_plain_disciplines
      .select{|d| !d.openmdao_impl.egmdo_surrogate && !d.openmdao_impl.support_derivatives} 
      .empty?
  end

  def support_derivatives?
    analysis.all_plain_disciplines
      .select{|d| 
        !d.openmdao_impl.support_derivatives
      } 
      .empty?
  end

  def is_package_specified?
    pname = self.analysis.root_analysis&.openmdao_impl&.package_name
    !pname.blank? && pname != NULL_PACKAGE_NAME
  end

  def top_packagename
    if is_package_specified?
      self.analysis.root_analysis.openmdao_impl.package_name
    else
      self.analysis.root_analysis.basename
    end
  end

  private
    def _ensure_default_impl
      self.parallel_group = false if parallel_group.blank?
      self.nonlinear_solver ||= Solver.new(name: "NonlinearBlockGS")
      self.linear_solver ||= Solver.new(name: "ScipyKrylov")
      self.use_units = true if use_units.nil?
      self.optimization_driver = :scipy_optimizer_slsqp if optimization_driver.blank?
      self.package_name = NULL_PACKAGE_NAME if package_name.blank?
    end
end
