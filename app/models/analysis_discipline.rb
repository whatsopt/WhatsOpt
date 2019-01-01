class AnalysisDiscipline < ApplicationRecord
  before_save :report_connections
  
  belongs_to :discipline
  belongs_to :analysis
 
  def self.build_analysis_discipline(disc, innermda)
    disc.type = :mda 
    disc.name = innermda.name
    mda_discipline = disc.build_analysis_discipline
    mda_discipline.analysis = innermda 
    innermda.parent = disc.analysis
    mda_discipline
  end

  def save!
    self.analysis.save!
    self.discipline.save!
  end

  def report_connections
    unless self.analysis.new_record?
      disc = self.discipline
      innermda = self.analysis
      outermda = self.discipline.analysis
      
      disc.create_variables_from_sub_analysis
      outermda.driver.create_variables_from_sub_analysis(innermda)    
      outermda.save!
    end
  end

end