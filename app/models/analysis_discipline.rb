class AnalysisDiscipline < ApplicationRecord
  
  belongs_to :discipline, autosave: true
  belongs_to :analysis, autosave: true
  
  def self.build_analysis_discipline(disc, innermda)
    disc.type = :mda
    mda_discipline = disc.build_analysis_discipline
    innermda.analysis_discipline = mda_discipline
    innermda.parent_id = disc.analysis.id
    disc.build_variables_from_sub_analysis
    disc.analysis.driver.build_variables_from_sub_analysis(innermda)
    mda_discipline
  end
  
end