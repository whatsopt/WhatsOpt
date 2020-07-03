# frozen_string_literal: true

module AnalysesHelper
  def lock_status(analysis)
    analysis.public ? "" : raw('<span><i class="fa fa-lock"></i></span>')
  end

  def link_to_analysis_if_authorized(analysis, user)
    if policy(analysis).show?
      link_to analysis.name, mda_path(analysis)
    else
      analysis.name
    end
  end

  def link_to_operation_if_authorized(ope, user)
    if policy(ope.analysis).show?
      link_to ope.name, operation_path(ope), id: ope.id
    else
      ope.name
    end
  end

  def link_to_final_operations_if_authorized(analysis, user)
    res = ""
    Operation.final.done(analysis).each do |ope|
      res += '<span style="margin: 0px 5px">'
      if policy(analysis).show?
        res += link_to ope.name, operation_path(ope)
      else
        res += ope.name
      end
      res += "</span>"
    end
    raw(res)
  end

  def badges(analysis)
    res = ""
    if analysis.is_metamodel_prototype?
      res += '<span class="badge badge-pill badge-success mr-2">MM</span>'
    end
    if analysis.uq_mode?
      res += '<span class="badge badge-pill badge-info mr-2">UQ</span>'
    end
    if analysis.has_objective?
      res += '<span class="badge badge-pill badge-primary mr-2">OPTIM</span>'
    end
    if analysis.nesting_depth > 2
      res += '<span class="badge badge-pill badge-danger mr-2">DEEP</span>'
    end
    raw(res)
  end
end
