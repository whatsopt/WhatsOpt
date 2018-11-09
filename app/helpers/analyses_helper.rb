module AnalysesHelper
  def lock_status(analysis)
    analysis.public ? '':raw('<span><i class="fa fa-lock"></i></span>')
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
    
  def link_to_operations_if_authorized(analysis, user)
    res = ""
    Operation.done(analysis).each do |ope|
      res += '<span style="margin: 0px 5px">' 
      if policy(analysis).show?
        res += link_to ope.name, operation_path(ope) 
      else
        res += ope.name
      end
      res += '</span>' 
    end
    raw(res)
  end

end