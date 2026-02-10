# frozen_string_literal: true

class OpenmdaoDisciplineImpl < ActiveRecord::Base
  include WhatsOpt::OpenmdaoModule

  belongs_to :discipline

  after_initialize :_ensure_default_impl

  validates :discipline, presence: true

  def name
    self.discipline.name
  end

  def path
    self.discipline.path
  end

  def build_copy
    OpenmdaoDisciplineImpl.new(
      implicit_component: implicit_component,
      support_derivatives: support_derivatives,
      egmdo_surrogate: egmdo_surrogate,
      jax_component: jax_component
    )
  end

  def openmdao_component_baseclass
    if self.jax_component
      if self.implicit_component
        "om.JaxImplicitComponent"
      else
        "om.JaxExplicitComponent"
      end
    elsif self.implicit_component
      "om.ImplicitComponent"
    elsif self.discipline.is_sub_optimization?
      "om.SubmodelComponent"
    else
      "om.ExplicitComponent"
    end
  end

  def numeric_input_vars
    @ivars ||= self.discipline.input_variables.active.numeric
  end

  def numeric_output_vars
    @ovars ||= self.discipline.output_variables.active.numeric
  end

  def py_filename
    if self.discipline.is_sub_optimization?
      "#{self.basename}_mdo.py"
    else
      super
    end
  end

  def py_basefilename
    if self.discipline.is_sub_optimization?
      "#{self.basename}_mdo_base.py"
    else
      super
    end
  end

  private
    def _ensure_default_impl
      self.implicit_component = false if implicit_component.nil?
      self.support_derivatives = false if support_derivatives.nil?
      self.egmdo_surrogate = false if egmdo_surrogate.nil?
      self.jax_component = false if jax_component.nil?
    end
end
