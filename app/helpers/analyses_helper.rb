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

  def link_to_design_project_if_any(analysis)
    res = ""
    project = analysis.design_project
    if project
      res += link_to "#{project.name}", design_project_url(project)
      res += " / "
    end
    raw(res)
  end
  
  def link_to_final_operations_if_authorized(analysis, user, nb=2)
    res = ""
    Operation.final.done(analysis).newest.first(nb).each do |ope|
      res += '<span style="margin: 0px 5px">'
      if policy(analysis).show?
        res += link_to ope.name, operation_path(ope)
      else
        res += ope.name
      end
      res += "</span>"
    end
    count = Operation.done(analysis).count
    if count > nb
      name = ' (+' + (count-nb).to_s + ')'
      # res += link_to name, mda_operations_path(analysis), title: "List Operations" 
      res += name
    end
    raw(res)
  end

  def badges(analysis)
    res = ""
    if analysis.is_metamodel_prototype?
      res += '<span class="badge rounded-pill bg-success me-2" title="Analysis reference for a meta-model discipline">MM</span>'
    end
    if analysis.uq_mode?
      res += '<span class="badge rounded-pill bg-info me-2" title="Analysis with uncertain inputs">UQ</span>'
    end
    if analysis.has_objective?
      res += '<span class="badge rounded-pill bg-primary me-2" title="Analysis with optimization problem">OPTIM</span>'
    end
    if analysis.nesting_depth > 2
      res += '<span class="badge rounded-pill bg-danger me-2" title="Analysis with more than 2 sub-analysis levels">DEEP</span>'
    end
    if analysis.packaged?
      res += '<span class="badge rounded-pill bg-warning me-2" title="Analysis is packaged">PKG</span>'
    end
    raw(res)
  end
end
