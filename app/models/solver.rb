# frozen_string_literal: true

class Solver < ActiveRecord::Base
  has_one :openmdao_analysis_impl

  after_initialize :set_defaults

  def runonce?
    name == "NonlinearRunOnce" || name == "LinearRunOnce"
  end

  def reckless?
    name == "RecklessNonlinearBlockGS"
  end

  def self.build_copy(solver)
    solver.dup
  end

  private
    def set_defaults
      self.atol ||= 1e-10
      self.rtol ||= 1e-10
      self.maxiter ||= 10
      self.iprint  ||= 1
      self.err_on_non_converge = true if err_on_non_converge.nil?
    end
end
