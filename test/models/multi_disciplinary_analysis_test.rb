require 'test_helper'

class MultiDisciplinaryAnalysisTest < ActiveSupport::TestCase
  
  test "should create an mda from a mda template excel file" do
    attach = sample_file('excel_mda_simple_sample.xlsm')
    mda = MultiDisciplinaryAnalysis.create!(attachment_attributes: {data: attach})
    assert mda.valid?
  end
  
  test "should be able to build nodes" do
    mda = multi_disciplinary_analyses(:cicav)
    assert_equal %w[Geometry Aerodynamics], mda.build_nodes.map {|n| n[:name]} 
  end
  
  test "should be able to build connections from user" do
    mda = multi_disciplinary_analyses(:cicav)
    geo = disciplines(:geometry)
    edges = mda.build_edges
    assert_includes edges, {from: "_U_", to: "#{geo.id}", name: "z"}
  end
  
  test "should not contain reflexive connection" do
    mda = multi_disciplinary_analyses(:cicav)
    edges = mda.build_edges
    assert_empty edges.select {|e| e[:to] == e[:from] }
  end
  
  test "should be able to build variable list" do
    mda = multi_disciplinary_analyses(:cicav)
    tree = mda.build_var_tree
    assert_equal ['Geometry', 'Aerodynamics'], tree.keys
    assert_equal ["x", "z"], tree['Geometry'][:in].map(&:name)
    assert_equal ["y", "z"], tree['Geometry'][:out].map(&:name)
    assert_equal ["y"], tree['Aerodynamics'][:in].map(&:name)
    assert_equal ["x"], tree['Aerodynamics'][:out].map(&:name)  
  end
end
