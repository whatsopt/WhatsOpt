# frozen_string_literal: true

require "test_helper"

class AnalysisTest < ActiveSupport::TestCase
  setup do
    @mda = analyses(:cicav)
  end

  test "when created, should have a driver discipline" do
    mda = Analysis.create!(name: "NewMDA")
    assert mda.valid?
    assert_equal 1, mda.disciplines.count
    assert_equal WhatsOpt::Discipline::NULL_DRIVER_NAME, mda.disciplines.first.name
  end

  test "should create new connections if needed" do
    @mda.disciplines.first.variables.create(name: "newvar", io_mode: "out")
    @mda.disciplines.second.variables.create(name: "newvar", io_mode: "in")
    assert_difference("Connection.count") do
      @mda.refresh_connections
    end
  end

  test "should not create new connection if everything is already connected" do
    assert_difference("Connection.count", 0) do
      @mda.refresh_connections
    end
  end

  test "should be able to build nodes" do
    assert_equal %w[__DRIVER__ Geometry Aerodynamics Propulsion], @mda.build_nodes.map { |n| n[:name] }
  end

  test "should be able to build connections from user" do
    geo = disciplines(:geometry).id.to_s
    aero = disciplines(:aerodynamics).id.to_s
    d = disciplines(:driver_cicav).id.to_s
    edges = @mda.build_edges
    edges = edges.map { |e| { from: e[:from], to: e[:to], name: e[:name] } }
    assert_equal 6, edges.count
    assert_includes edges, from: geo, to: aero, name: "yg"
    assert_includes edges, from: aero, to: geo, name: "ya"
    assert_includes edges, from: d, to: geo, name: "x1,z"
    assert_includes edges, from: d, to: aero, name: "z"
    assert_includes edges, from: aero, to: d, name: "y2"
    assert_includes edges, from: geo, to: d, name: "obj"
  end

  test "should not contain reflexive connection" do
    edges = @mda.build_edges
    assert_empty edges.select { |e| e[:to] == e[:from] }
  end

  test "should get XDSM json" do
    json = @mda.to_xdsm_json
    xdsm = JSON.parse(json)
    assert_equal ["root"], xdsm.keys() 
  end

  test "should get XDSM json of nested analysis" do
    json =  analyses(:outermda).to_xdsm_json
    xdsm = JSON.parse(json)
    assert_equal ["root", analyses(:innermda).name], xdsm.keys()
  end

  test "should be able to build variable list" do
    tree = @mda.build_var_infos
    assert_equal @mda.disciplines.map(&:id), tree.keys
    geom_id = Discipline.where(name: "Geometry").take.id
    aero_id = Discipline.where(name: "Aerodynamics").take.id
    assert_equal ["x1", "ya", "z"], tree[geom_id][:in].map { |h| h[:name] }.sort
    assert_equal ["obj", "yg"], tree[geom_id][:out].map { |h| h[:name] }.sort
    assert_equal ["yg", "z"], tree[aero_id][:in].map { |h| h[:name] }.sort
    assert_equal ["y2", "ya"], tree[aero_id][:out].map { |h| h[:name] }.sort
  end

  test "should get design variables" do
    assert_equal ["x1", "z"], @mda.design_variables.map(&:name).sort
  end
  test "should get parameters" do
    assert_equal ["x1", "z"], @mda.input_variables.map(&:name).sort
  end
  test "should get objectives" do
    assert_equal ["obj"], @mda.min_objective_variables.map(&:name).sort
  end
  test "should get responses" do
    assert_equal ["obj", "y2"], @mda.response_variables.map(&:name).sort
  end

  test "should get direct plain disciplines" do
    @outermda = analyses(:outermda)
    assert_equal ["Disc", "VacantDiscipline"], @outermda.plain_disciplines.map(&:name)
  end

  test "should get all plain disciplines" do
    @outermda = analyses(:outermda)
    assert_equal ["Disc", "VacantDiscipline", "PlainDiscipline"], @outermda.all_plain_disciplines.map(&:name)
  end

  test "should have default openmdao impl once created" do
    @mda = Analysis.create!(name: "NewMDA")
    impl = @mda.openmdao_impl
    assert impl
    assert_equal "NonlinearBlockGS", impl.nonlinear_solver.name
    assert_equal "ScipyKrylov", impl.linear_solver.name
  end

  test "should know if it is a metamodel" do
    mda = analyses(:outermda)
    assert_not mda.is_metamodel?
    mda = analyses(:cicav_metamodel_analysis)
    assert mda.is_metamodel?
  end

  test "should copy an analysis" do
    copy = @mda.create_copy!
    assert_equal Connection.of_analysis(@mda).count, Connection.of_analysis(copy).count
  end

  test "should copy a metamodel" do
    mda = analyses(:cicav_metamodel_analysis)
    copy = mda.create_copy!
    assert copy.is_metamodel?
    orig_conns = Connection.of_analysis(mda)
    copy_conns = Connection.of_analysis(copy)
    assert_equal orig_conns.size, copy_conns.size
  end

  test "should copy of a copy of a metamodel and predict with even middle copy removed" do
    # skip "doe copy not yet implemented"
    mda = analyses(:cicav_metamodel_analysis)
    copy = mda.create_copy!
    assert copy.is_metamodel?
    x = [[1, 3, 4], [8, 9, 10], [5, 4, 3]]
    mm = copy.disciplines.last.meta_model
    assert_not_equal mda.disciplines.last, mm
    y = mm.predict(x)
    assert_in_delta 4.925, y[0][0]
    assert_equal x.size, y.size
    mda.operations.reverse.map(&:destroy)
    mda.destroy
    mm.reload
    y = mm.predict(x)
    assert_in_delta 4.925, y[0][0]
    assert_equal x.size, y.size
  end

  test "should copy a sub-analysis" do
    mda = analyses(:outermda)
    mda.disciplines.count
    copy = mda.create_copy!
    orig_conns = Connection.of_analysis(mda)
    copy_conns = Connection.of_analysis(copy)
    # Connection.print(orig_conns)
    # puts
    # Connection.print(copy_conns)
    assert_equal orig_conns.size, copy_conns.size
  end

  test "should import a metamodel" do
    mda = analyses(:singleton)
    disc = disciplines(:disc_cicav_metamodel)
    mda.import!(disc.analysis, [disc.id])
    mda.reload
    assert_equal 3, mda.disciplines.count
    assert_equal WhatsOpt::Discipline::METAMODEL, mda.disciplines.last.type
  end

end
