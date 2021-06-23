# frozen_string_literal: true

require "test_helper"

class AnalysisDisciplineTest < ActiveSupport::TestCase
  test "should report connections when saving analysis discipline" do
    disc = disciplines(:outermda_vacant_discipline)
    outermda = disc.analysis
    innermda = analyses(:singleton)
    ad = disc.build_analysis_discipline(analysis: innermda)
    innermda.parent = outermda
    outervars = Variable.of_analysis(outermda).map(&:name)
    refute outervars.include?("u")
    refute outervars.include?("v")
    innermda.save!
    outervars = Variable.of_analysis(outermda).map(&:name)
    assert Variable.of_analysis(outermda).map(&:name).include?("u")
    assert Variable.of_analysis(outermda).map(&:name).include?("v")
  end
end
