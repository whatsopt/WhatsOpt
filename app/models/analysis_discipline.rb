class AnalysisDiscipline < ApplicationRecord
  before_save :report_connections 
  
  belongs_to :discipline
  belongs_to :analysis
  
  def self.build_analysis_discipline(disc, innermda)
    disc.type = :mda
    mda_discipline = disc.build_analysis_discipline(analysis_id: innermda.id)
    innermda.parent_id = disc.analysis.id    
    mda_discipline
  end
  
  def report_connections
    disc = self.discipline
    innermda = self.analysis
    outermda = self.discipline.analysis
    
    disc.create_variables_from_sub_analysis
    outermda.driver.create_variables_from_sub_analysis(innermda)    
    outermda.save!
  end
  
end