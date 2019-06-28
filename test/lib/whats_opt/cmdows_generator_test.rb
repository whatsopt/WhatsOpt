# frozen_string_literal: true

require "test_helper"
require "whats_opt/cmdows_generator"

class CmdowsGeneratorTest < ActiveSupport::TestCase
  def setup
    @mda = analyses(:cicav)
    @cmdowsgen = WhatsOpt::CmdowsGenerator.new(@mda)
  end

  test "should generate cmdows xml" do
    content, filename = @cmdowsgen.generate
    assert_equal Nokogiri::XML(content).xpath("//designCompetence").size, @mda.disciplines.nodes.count
    assert_equal "cicav.xml", filename
  end
end
