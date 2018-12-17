class AnalysisDiscipline < ApplicationRecord
  before_save :report_connections 
  
  belongs_to :discipline
  belongs_to :analysis
 
  def self.build_analysis_discipline(disc, innermda)
    mda_discipline = innermda.build_analysis_discipline
    mda_discipline.discipline = disc
    mda_discipline.discipline.type = :mda
    mda_discipline.discipline.name = mda_discipline.analysis.name 
    mda_discipline.analysis.parent_id = mda_discipline.discipline.analysis.id    
    mda_discipline
  end

  def save!
    self.analysis.save!
    self.discipline.save!
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