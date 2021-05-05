# frozen_string_literal: true

module DesignProjectsHelper
  def link_to_analyses_if_authorized(design_project, nb=3)
    res = ""
    design_project.analyses.roots.each do |mda|
      res += '<span style="margin: 0px 5px">'
      if policy(mda).show?
        res += link_to mda.name, mda_path(mda)
      else
        res += mda.name
      end
      res += "</span>"
    end
    raw(res)
  end
end
