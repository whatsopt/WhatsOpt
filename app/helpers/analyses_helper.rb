# frozen_string_literal: true

module AnalysesHelper

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
    elsif analysis.mono_disciplinary?
      res += '<span class="badge rounded-pill bg-secondary me-2" title="Analysis has one discipline">DISC</span>'
    end
    if analysis.uq_mode?
      res += '<span class="badge rounded-pill bg-info me-2" title="Analysis with uncertain inputs">UQ</span>'
    end
    if analysis.has_objective?
      res += '<span class="badge rounded-pill bg-primary me-2" title="Analysis with optimization problem">OPTIM</span>'
    end
    if analysis.packaged?
      res += '<span class="badge rounded-pill bg-warning me-2" title="Analysis is packaged">PKG</span>'
    end
    if analysis.nesting_depth > 2
      res += '<span class="badge rounded-pill bg-danger me-2" title="Analysis with more than 2 sub-analysis levels">DEEP</span>'
    end
    raw(res)
  end

  def owners(analysis)
    res = "<span class='me-2'>#{analysis.owner.login}"
    analysis.co_owners.each_with_index do |u, i|
      if i+1 == analysis.co_owners.size
        res += "<span class='me-2'> and #{u.login}"
      else
        res += "<span class='me-2'>, #{u.login}"
      end
    end
    res += "</span>"
    raw(res)
  end

  def analysis_access(analysis)
    res = ""
    if analysis.locked
      res += ' <i class="fa fa-lock"  title="Analysis is readonly"></i></span>'
    end
    unless analysis.public
      res += ' <i class="fas fa-user-secret" title="Analysis with restricted access"></i>'
    end
    if analysis.co_owners.count > 0
      res += ' <i class="fas fa-users-cog" title="Analysis has co-owners"></i>'
    end
    raw(res) 
  end
end
