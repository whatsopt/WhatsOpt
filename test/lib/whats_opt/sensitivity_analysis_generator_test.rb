require 'test_helper'
require 'whats_opt/sensitivity_analysis_generator'
require 'tmpdir'
require 'pathname'

class SensitivityAnalysisGeneratorTest < ActiveSupport::TestCase

  def setup
    @ope = operations(:screening)
    @sagen = WhatsOpt::SensitivityAnalysisGenerator.new(@ope)
  end

  test "should generate sa code for an analysis" do
    Dir.mktmpdir do |dir|
      # dir = "/tmp"
      filepath = @sagen._generate_code dir
      assert File.exists?(filepath)
    end
  end
    
end