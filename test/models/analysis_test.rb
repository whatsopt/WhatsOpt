require 'test_helper'

class AnalysisTest < ActiveSupport::TestCase
  
  test "when created, should have a driver discipline" do
    mda = Analysis.create!( {name: 'NewMDA'} )
    assert mda.valid?
    assert_equal 1, mda.disciplines.count
    assert_equal WhatsOpt::Discipline::NULL_DRIVER_NAME, mda.disciplines.first.name
  end
   
  test "should create an mda from a mda template excel file" do
    attach = sample_file('excel_mda_simple_sample.xlsx')
    mda = Analysis.create!(attachment_attributes: {data: attach})
    assert mda.to_mda_viewer_json
    assert mda.valid?
    assert_equal 3, mda.design_variables.count
    assert_equal 1, mda.optimization_variables.count
  end

  test "should be able to build nodes" do
    mda = analyses(:cicav)
    assert_equal %w[Geometry Aerodynamics], mda.build_nodes.map {|n| n[:name]} 
  end
  
  test "should be able to build connections from user" do
    mda = analyses(:cicav)
    geo = disciplines(:geometry).id.to_s
    aero = disciplines(:aerodynamics).id.to_s
    u = "_U_"
    edges = mda.build_edges
    assert_equal 6, edges.count
    assert_includes edges, {from: geo, to: aero, name: "yg"}
    assert_includes edges, {from: aero, to: geo, name: "ya"}
    assert_includes edges, {from: u, to: geo, name: "x1,z"}
    assert_includes edges, {from: u, to: aero, name: "z"}
    assert_includes edges, {from: aero, to: u, name: "y2"}
    assert_includes edges, {from: geo, to: u, name: "obj"}
  end
  
  test "should not contain reflexive connection" do
    mda = analyses(:cicav)
    edges = mda.build_edges
    assert_empty edges.select {|e| e[:to] == e[:from] }
  end
  
  test "should be able to build variable list" do
    mda = analyses(:cicav)
    tree = mda.build_var_infos
    assert_equal mda.disciplines.nodes.all.map(&:id), tree.keys
    geom_id = Discipline.where(name: 'Geometry').take.id
    aero_id = Discipline.where(name: 'Aerodynamics').take.id
    assert_equal ["x1", "ya", "z"], tree[geom_id][:in].map{|h| h[:name]}.sort
    assert_equal ["obj", "yg"], tree[geom_id][:out].map{|h| h[:name]}.sort
    assert_equal ["yg", "z"], tree[aero_id][:in].map{|h| h[:name]}.sort
    assert_equal ["y2", "ya"], tree[aero_id][:out].map{|h| h[:name]}.sort
  end

end
