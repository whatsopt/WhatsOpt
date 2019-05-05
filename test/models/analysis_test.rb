require 'test_helper'

class AnalysisTest < ActiveSupport::TestCase
  
  setup do
   @mda = analyses(:cicav) 
  end

  test "when created, should have a driver discipline" do
    mda = Analysis.create!( {name: 'NewMDA'} )
    assert mda.valid?
    assert_equal 1, mda.disciplines.count
    assert_equal WhatsOpt::Discipline::NULL_DRIVER_NAME, mda.disciplines.first.name
  end
   
  test "should create an mda from a mda template excel file" do
    attach = sample_file('excel_mda_dummy.xlsx')
    mda = Analysis.create!(attachment_attributes: {data: attach})
    assert mda.to_mda_viewer_json
    assert mda.valid?
    assert_equal 4, mda.parameter_variables.count
    assert_equal 1, mda.response_variables.count
  end

  test "should create new connections if needed" do
    @mda.disciplines.first.variables.create(name: 'newvar', io_mode: 'out')
    @mda.disciplines.second.variables.create(name: 'newvar', io_mode: 'in')
    assert_difference('Connection.count') do
      @mda.refresh_connections
    end
  end 

  test "should not create new connection if everything is already connected" do
    assert_difference('Connection.count', 0) do
     @mda.refresh_connections
    end
  end
    
  test "should be able to build nodes" do
    assert_equal %w[__DRIVER__ Geometry Aerodynamics Propulsion], @mda.build_nodes.map {|n| n[:name]} 
  end
  
  test "should be able to build connections from user" do
    geo = disciplines(:geometry).id.to_s
    aero = disciplines(:aerodynamics).id.to_s
    d = disciplines(:driver_cicav).id.to_s
    edges = @mda.build_edges
    edges = edges.map{|e| {from: e[:from], to: e[:to], name: e[:name]}}
    assert_equal 6, edges.count
    assert_includes edges, {from: geo, to: aero, name: "yg"}
    assert_includes edges, {from: aero, to: geo, name: "ya"}
    assert_includes edges, {from: d, to: geo, name: "x1,z"}
    assert_includes edges, {from: d, to: aero, name: "z"}
    assert_includes edges, {from: aero, to: d, name: "y2"}
    assert_includes edges, {from: geo, to: d, name: "obj"}
  end
  
  test "should not contain reflexive connection" do
    edges = @mda.build_edges
    assert_empty edges.select {|e| e[:to] == e[:from] }
  end
  
  test "should be able to build variable list" do
    tree = @mda.build_var_infos
    assert_equal @mda.disciplines.map(&:id), tree.keys
    geom_id = Discipline.where(name: 'Geometry').take.id
    aero_id = Discipline.where(name: 'Aerodynamics').take.id
    assert_equal ["x1", "ya", "z"], tree[geom_id][:in].map{|h| h[:name]}.sort
    assert_equal ["obj", "yg"], tree[geom_id][:out].map{|h| h[:name]}.sort
    assert_equal ["yg", "z"], tree[aero_id][:in].map{|h| h[:name]}.sort
    assert_equal ["y2", "ya"], tree[aero_id][:out].map{|h| h[:name]}.sort
  end

  test "should get design variables" do
    assert_equal ["x1", "z"], @mda.design_variables.map(&:name).sort
  end  
  test "should get parameters" do
    assert_equal ["x1", "z"], @mda.parameter_variables.map(&:name).sort
  end  
  test "should get objectives" do
    assert_equal ["obj"], @mda.min_objective_variables.map(&:name).sort
  end  
  test "should get responses" do
    assert_equal ["obj", "y2"], @mda.response_variables.map(&:name).sort
  end  

  test "should get direct plain disciplines" do
    @outermda = analyses(:outermda)  
    assert_equal ['Disc', 'VacantDiscipline'], @outermda.plain_disciplines.map(&:name) 
  end

  test "should get all plain disciplines" do
    @outermda = analyses(:outermda)
    assert_equal ['Disc', 'VacantDiscipline', 'PlainDiscipline'], @outermda.all_plain_disciplines.map(&:name)  
  end

  test "should have default openmdao impl once created" do
    @mda = Analysis.create!( {name: 'NewMDA'} )
    impl = @mda.openmdao_impl
    assert impl
    assert_equal "NonlinearBlockGS", impl.nonlinear_solver.name
    assert_equal "ScipyKrylov", impl.linear_solver.name
  end
end
