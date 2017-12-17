require 'test_helper'

class MultiDisciplinaryAnalysisTest < ActiveSupport::TestCase
  
  test "when created, should have a controller discipline" do
    mda = multi_disciplinary_analyses(:cicav)
    assert mda.valid?
  end
   
  test "should create an mda from a mda template excel file" do
    attach = sample_file('excel_mda_simple_sample.xlsx')
    mda = MultiDisciplinaryAnalysis.create!(attachment_attributes: {data: attach})
    assert mda.valid?
    assert_equal 3, mda.design_variables.count
    assert_equal 1, mda.optimization_variables.count
  end

  test "should be able to build nodes" do
    mda = multi_disciplinary_analyses(:cicav)
    assert_equal %w[Geometry Aerodynamics], mda.build_nodes.map {|n| n[:name]} 
  end
  
  test "should be able to build connections from user" do
    mda = multi_disciplinary_analyses(:cicav)
    geo = disciplines(:geometry).id.to_s
    aero = disciplines(:aerodynamics).id.to_s
    u = "_U_"
    edges = mda.build_edges
    assert_equal 7, edges.count
    assert_includes edges, {from: geo, to: aero, name: "y,z"}
    assert_includes edges, {from: aero, to: geo, name: "x"}
    assert_includes edges, {from: u, to: geo, name: "z"}
    assert_includes edges, {from: u, to: geo, name: "z"}
    assert_includes edges, {from: u, to: aero, name: "z"}
    assert_includes edges, {from: aero, to: u, name: "z_pending"}
    assert_includes edges, {from: u, to: geo, name: "x_pending"}
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
    assert_equal ["x_pending", "x", "z"], tree['Geometry'][:in].map(&:name)
    assert_equal ["y", "z"], tree['Geometry'][:out].map(&:name)
    assert_equal ["z", "y"], tree['Aerodynamics'][:in].map(&:name)
    assert_equal ["x", "z_pending"], tree['Aerodynamics'][:out].map(&:name)  
  end
end
