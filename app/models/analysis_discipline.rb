# frozen_string_literal: true

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
    analysis.save!
    discipline.save!
  end

  def report_connections
    unless analysis.new_record?
      disc = discipline
      innermda = analysis
      outermda = discipline.analysis

      disc.create_variables_from_sub_analysis
      outermda.driver.create_variables_from_sub_analysis(innermda)
      outermda.save!
    end
  end
end
