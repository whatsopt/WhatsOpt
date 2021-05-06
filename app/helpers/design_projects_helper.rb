# frozen_string_literal: true

module DesignProjectsHelper
  def link_to_analyses_if_authorized(design_project, nb=5)
    res = ""
    design_project.analyses.roots.latest.first(nb).each do |mda|
      res += '<span style="margin: 0px 5px">'
      if policy(mda).show?
        res += link_to mda.name, mda_path(mda)
      else
        res += mda.name
      end
      res += "</span>"
    end
    count = design_project.analyses.roots.count

    if count > nb
      res += "<span style=\"margin: 0px 5px\">(+#{count-nb})</span>"
    end
    raw(res)
  end
end
