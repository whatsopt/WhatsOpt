class Solver < ActiveRecord::Base

  has_many :openmdao_analysis_impl

  after_initialize :set_defaults

  private

  def set_defaults
    self.atol ||= 1e-10
    self.rtol ||= 1e-10
    self.maxiter ||= 10
    self.iprint  ||= 1
    self.err_on_maxiter = true if self.err_on_maxiter.nil?
  end

end