class AnalysisDiscipline < ApplicationRecord
  
  belongs_to :discipline, autosave: true
  has_one :analysis, autosave: true
  
  def self.build_analysis_discipline(disc, innermda)
    mda_discipline = disc.build_analysis_discipline
    innermda.analysis_discipline = mda_discipline
  end
  
end