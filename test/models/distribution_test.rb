require 'test_helper'

class DistributionTest < ActiveSupport::TestCase

  test "should be well formed" do
    dist = distributions(:singleton_u_uq)
    json = DistributionSerializer.new(dist).as_json
    assert_equal 'Normal', json[:kind]
    assert_equal 2, json[:options_attributes].size
  end

  test "should be present in mda json for uncertain variables" do
    json = JSON.parse(analyses(:singleton).to_mda_viewer_json)
    variables = []
    json["vars"].each do |d, vars|
      variables << vars["out"]
    end
    u = variables.flatten.detect{|v| v["name"]=="u"}
    expected = {"kind"=>"Normal", 
                "options_attributes" => [
                  {"name" => "mu", "value" => "0.5"}, 
                  {"name" => "sigma", "value" => "2.0"},
                ]}
    assert_equal ["kind", "options_attributes"], u["distribution_attributes"].keys
    assert_equal 2, u["distribution_attributes"]["options_attributes"].size
  end

  test "should not be present in mda json for determinist variables" do
    json = JSON.parse(analyses(:cicav).to_mda_viewer_json)
    variables = []
    json["vars"].each do |d, vars|
      variables << vars["out"]
    end
    x1 = variables.flatten.detect{|v| v["name"]=="x1"} 
    assert_nil x1["distribution_attributes"]   
  end

end
