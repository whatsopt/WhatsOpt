class OpenmdaoDisciplineImpl < ActiveRecord::Base

  belongs_to :discipline

  after_initialize :_ensure_default_impl

  private 

  def _ensure_default_impl
    self.implicit_component = false if self.implicit_component.nil?
    self.support_derivatives = false if self.support_derivatives.nil?
  end

end