# frozen_string_literal: true

require "test_helper"
require "whats_opt/salib_sensitivity_analyser"
require "tmpdir"
require "pathname"

class SalibSensitivityAnalyserTest < ActiveSupport::TestCase

  test "should compute hsic" do
    @ope = operations(:doe_hsic)
    @analyser = WhatsOpt::HsicSensitivityAnalyser.new(@ope)
    hsic = @analyser.get_hsic_sensitivity
    
    expected = {indices:[0.0014121409195806053, 0.001418468960398962, 0.0007061936384376915, 0.0002129569288513162, 8.460438189180596e-05], r2:[0.06803236078292796, 0.06834374947404051, 0.034028210220661076, 0.010262464507910463, 0.004078202941354846], pvperm:[0.0, 0.0, 0.009900990099009901, 0.3069306930693069, 0.900990099009901], pvas:[0.0003317619419649116, 0.0005081353448532153, 0.0016678701675430965, 0.39159553260140195, 0.8348439572390963]}
    assert_equal(hsic.indices, expected[:indices]) 
    assert_equal(hsic.r2, expected[:r2]) 
    hsic.pvas.zip(expected[:pvas]).each do |act, exp|
      assert_in_delta(act, exp, delta=0.1) 
    end
    hsic.pvperm.zip(expected[:pvperm]).each do |act, exp|
      assert_in_delta(act, exp, delta=0.1) 
    end
  end
  
end