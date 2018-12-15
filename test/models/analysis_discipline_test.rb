require 'test_helper'

class AnalysisDisciplineTest < ActiveSupport::TestCase
  
  test "should create ancestor when creating analysis_discipline" do
    disc = disciplines(:outermda_vacant_discipline)
    innermda = analyses(:innermda)
    outermda = analyses(:outermda)
    ad = AnalysisDiscipline.build_analysis_discipline(disc, innermda)
    ad.save!
    innermda.reload
    assert innermda.has_parent?
    assert outermda, innermda.ancestors
  end

end
