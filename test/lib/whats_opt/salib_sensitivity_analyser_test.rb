# frozen_string_literal: true

require "test_helper"
require "whats_opt/salib_sensitivity_analyser"
require "tmpdir"
require "pathname"

class SalibSensitivityAnalyserTest < ActiveSupport::TestCase
  def setup
    @ope = operations(:morris_doe)
    @analyser = WhatsOpt::SalibSensitivityAnalyser.new(@ope)
  end

  test "should generate sa code for an analysis" do
    Dir.mktmpdir do |dir|
      # dir = "/tmp"
      filepath = @analyser._generate_code dir
      assert File.exist?(filepath)
    end
  end
end
