# frozen_string_literal: true

class OpenmdaoDisciplineImpl < ActiveRecord::Base
  belongs_to :discipline

  after_initialize :_ensure_default_impl

  def build_copy
    OpenmdaoDisciplineImpl.new(
      implicit_component: implicit_component,
      support_derivatives: support_derivatives,
      egmdo_surrogate: egmdo_surrogate
    )
  end

  def openmdao_component_baseclass
    if self.implicit_component 
      "om.ImplicitComponent"
    elsif self.discipline.is_sub_optimization?
      "om.SubmodelComponent"
    else
      "om.ExplicitComponent"
    end
  end

  def py_filename
    if self.discipline.is_sub_optimization?
      "#{self.discipline.basename}_mdo.py"
    else
      self.discipline.py_filename
    end
  end

  def py_basefilename
    if self.discipline.is_sub_optimization?
      "#{self.discipline.basename}_mdo_base.py"
    else
      self.discipline.py_basefilename
    end
  end

  private
    def _ensure_default_impl
      self.implicit_component = false if implicit_component.nil?
      self.support_derivatives = false if support_derivatives.nil?
      self.egmdo_surrogate = false if egmdo_surrogate.nil?
    end
end
