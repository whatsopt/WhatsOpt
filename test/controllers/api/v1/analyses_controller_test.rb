# frozen_string_literal: true

require "test_helper"

class Api::V1::AnalysesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user1 = users(:user1)
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
    @mda = analyses(:cicav)
    @mda2 = analyses(:fast)
    @disc = @mda.disciplines.nodes.first
  end

  test "should get only root authorized mdas" do
    get api_v1_mdas_url, as: :json, headers: @auth_headers
    assert_response :success
    analyses = JSON.parse(response.body)
    assert_equal Analysis.count-2, analyses.size # ALL - {one user3 private, one sub-analysis}
  end

  test "should get all mdas even sub ones" do
    get api_v1_mdas_url(with_sub_analyses: true), as: :json, headers: @auth_headers
    assert_response :success 
    analyses = JSON.parse(response.body)
    assert_equal Analysis.count-1, analyses.size # ALL - {one user3 private}
  end

  test "should create a mda" do
    post api_v1_mdas_url, params: { analysis: { name: "TestMda" } }, as: :json, headers: @auth_headers
    assert_response :success
  end

  test "should create sellar mda" do
    mda_params = { 'analysis': { 'name': "Sellar", 'disciplines_attributes': [{ 'name': "__DRIVER__", 'variables_attributes': [{ 'name': "x", 'io_mode': "out", 'type': "Float", 'shape': "1", 'units': nil, 'desc': "", 'parameter_attributes': { 'init': "2.0" }, 'scaling_attributes': { 'ref': "3.0" } }, { 'name': "z", 'io_mode': "out", 'type': "Float", 'shape': "(2,)", 'units': nil, 'desc': "", 'parameter_attributes': { 'init': "[5.0, 2.0]" } }, { 'name': "obj", 'io_mode': "in", 'type': "Float", 'shape': "1", 'units': nil, 'desc': "" }, { 'name': "g1", 'io_mode': "in", 'type': "Float", 'shape': "1", 'units': nil, 'desc': "constraint" }, { 'name': "g2", 'io_mode': "in", 'type': "Float", 'shape': "1", 'units': nil, 'desc': "" }] }, { 'name': "Disc1", 'variables_attributes': [{ 'name': "x", 'io_mode': "in", 'type': "Float", 'shape': "1", 'units': nil, 'desc': "" }, { 'name': "y2", 'io_mode': "in", 'type': "Float", 'shape': "1", 'units': nil, 'desc': "" }, { 'name': "z", 'io_mode': "in", 'type': "Float", 'shape': "(2,)", 'units': nil, 'desc': "" }, { 'name': "y1", 'io_mode': "out", 'type': "Float", 'shape': "1", 'units': nil, 'desc': "" }] }, { 'name': "Disc2", 'variables_attributes': [{ 'name': "y2", 'io_mode': "out", 'type': "Float", 'shape': "1", 'units': nil, 'desc': "" }, { 'name': "y1", 'io_mode': "in", 'type': "Float", 'shape': "1", 'units': nil, 'desc': "" }, { 'name': "z", 'io_mode': "in", 'type': "Float", 'shape': "(2,)", 'units': nil, 'desc': "" }] }, { 'name': "Functions", 'variables_attributes': [{ 'name': "x", 'io_mode': "in", 'type': "Float", 'shape': "1", 'units': nil, 'desc': "" }, { 'name': "y1", 'io_mode': "in", 'type': "Float", 'shape': "1", 'units': nil, 'desc': "" }, { 'name': "y2", 'io_mode': "in", 'type': "Float", 'shape': "1", 'units': nil, 'desc': "" }, { 'name': "z", 'io_mode': "in", 'type': "Float", 'shape': "(2,)", 'units': nil, 'desc': "" }, { 'name': "obj", 'io_mode': "out", 'type': "Float", 'shape': "1", 'units': nil, 'desc': "" }, { 'name': "g1", 'io_mode': "out", 'type': "Float", 'shape': "1", 'units': nil, 'desc': "constraint" }, { 'name': "g2", 'io_mode': "out", 'type': "Float", 'shape': "1", 'units': nil, 'desc': "" }] }] } }
    post api_v1_mdas_url, params: mda_params, as: :json, headers: @auth_headers
    assert_response :success
    analysis = Analysis.last
    analysis.driver.output_variables.each do |v|
      case v.name
      when "x"
        assert_equal "2.0", v.parameter.init
        assert_equal "3.0", v.scaling.ref
      when "z"
        assert_equal "[5.0, 2.0]", v.parameter.init
      else
        assert false, "#{v.name} is forbidden"
      end
    end
  end

  test "should update a mda" do
    put api_v1_mda_url(@mda), params: { analysis: { name: "TestNewName" } }, as: :json, headers: @auth_headers
    assert_response :success
    get api_v1_mda_url(@mda), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal "TestNewName", resp["name"]
  end

  test "should get xdsm format" do
    get api_v1_mda_url(@mda, format: "xdsm"), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal @mda.disciplines.count, resp["nodes"].size
  end

  test "should create nested analysis" do
    assert_difference("Discipline.count", 4) do
      assert_difference("Analysis.count", 2) do
        mda_attrs =
          { "name": "Outer", "disciplines_attributes": [
            { "name": "__DRIVER__", "variables_attributes": [
              { "name": "x", "io_mode": "out", "type": "Float", "shape": "1", "units": "", "desc": "",
                    "parameter_attributes": { "init": "2.0" } },
              { "name": "y", "io_mode": "in", "type": "Float", "shape": "1", "units": "" }] },
            { "name": "InnerDiscipline", "sub_analysis_attributes":
              { "name": "MyInner", "disciplines_attributes": [
                { "name": "__DRIVER__", "variables_attributes": [
                    { "name": "x", "io_mode": "out", "type": "Float", "shape": "1", "units": "",  "desc": "",
                        "parameter_attributes": { "init": "2.0" } },
                    { "name": "y", "io_mode": "in", "type": "Float", "shape": "1", "units": "",  "desc": "" }] },
                { "name": "Disc", "variables_attributes": [
                  { "name": "x", "io_mode": "in", "type": "Float", "shape": "1", "units": "",  "desc": "",
                    "parameter_attributes": { "init": "2.0" } },
                  { "name": "y", "io_mode": "out", "type": "Float", "shape": "1", "units": "",  "desc": "" }
                ] }
              ] }
            }
          ] }
        post api_v1_mdas_url, params: { analysis: mda_attrs }, as: :json, headers: @auth_headers
        assert_response :success
      end
    end
    inner = Analysis.last
    outer = Analysis.second_to_last
    inner_disc = Discipline.find_by_name("MyInner")
    assert_equal 2, inner_disc.variables.count
    assert_equal "x", inner_disc.input_variables.first.name
    assert_equal "y", inner_disc.output_variables.first.name
    assert_equal "Outer", outer.name
    assert_equal "MyInner", inner.name
    assert_equal 2, Connection.of_analysis(outer).count
    assert_equal 2, Connection.of_analysis(inner).count
    assert_equal outer.id, inner.parent.id
    assert_equal @user1, outer.owner
    assert_equal @user1, inner.owner
  end

  test "should create sellar optim analysis" do
    sellar_optim = JSON.load(sample_file("sellar_optim.json"))
    mda_params = { analysis: sellar_optim }
    post api_v1_mdas_url, params: mda_params, as: :json, headers: @auth_headers
    inner = Analysis.find_by_name("Sellar")
    outer = Analysis.find_by_name("SellarOptim")
    assert_equal outer.id, inner.parent.id
    assert_equal @user1, outer.owner
    assert_equal @user1, inner.owner
  end

  test "should update descendants attributes" do
    @outer = analyses(:outermda)
    public = true
    patch api_v1_mda_url(@outer), params: { analysis: { public: public } }, as: :json, headers: @auth_headers
    @inner = analyses(:innermda)
    assert_equal public, @inner.public
    public = false
    patch api_v1_mda_url(@outer), params: { analysis: { public: public } }, as: :json, headers: @auth_headers
    assert_equal public, @inner.reload.public
  end

  test "should have an openmdao implementation in mda_viewer json" do
    mdajson = JSON.parse(@mda.to_mda_viewer_json)
    assert_equal({ "name" => "NonlinearBlockGS", "atol" => 1.0e-06, "rtol" => 1.0e-10,
                  "maxiter" => 7, "err_on_non_converge" => true, "iprint" => 2 }, mdajson["impl"]["openmdao"]["nonlinear_solver"])
    assert_equal({ "name" => "ScipyKrylov", "atol" => 1.0e-08, "rtol" => 1.0e-07,
                  "maxiter" => 10, "err_on_non_converge" => false, "iprint" => 1 }, mdajson["impl"]["openmdao"]["linear_solver"])
    assert_equal false, mdajson["impl"]["openmdao"]["components"]["parallel_group"]
    assert 3, mdajson["impl"]["openmdao"]["components"]["nodes"].size
  end

  test "should import a discipline from another analysis" do
    beforeConnsNb = Connection.of_analysis(@mda).size
    mda2 = analyses(:innermda)
    disc = disciplines(:innermda_discipline)
    put api_v1_mda_url(@mda), params: {analysis: {import: {analysis: mda2.id, disciplines: [disc.id]}}}, 
        as: :json, headers: @auth_headers
    @mda.reload
    newDisc = @mda.disciplines.last
    assert_equal disc.name, newDisc.name
    assert_equal 11, Connection.of_analysis(@mda).count
    # Connection.of_analysis(@mda).each do |conn|
    #   puts "Connection #{conn.from.name} from #{conn.from.discipline.name} to #{conn.to.discipline.name}"
    # end
    #
    # Connection z from __DRIVER__ to Aerodynamics
    # Connection z from __DRIVER__ to Geometry
    # Connection z from __DRIVER__ to PlainDiscipline
    # Connection x1 from __DRIVER__ to Geometry
    # Connection x2 from __DRIVER__ to PlainDiscipline
    # Connection y1 from __DRIVER__ to PlainDiscipline
    # Connection obj from Geometry to __DRIVER__
    # Connection yg from Geometry to Aerodynamics
    # Connection ya from Aerodynamics to Geometry
    # Connection y2 from Aerodynamics to __DRIVER__
    # Connection y from PlainDiscipline to __DRIVER__
  end

  test "should import a metamodel" do
    orig_count = @mda.disciplines.count
    mda2 = analyses(:singleton_mm)
    disc = disciplines(:disc_singleton_mm)
    put api_v1_mda_url(@mda), params: {analysis: {import: {analysis: mda2.id, disciplines: [disc.id]}}}, 
      as: :json, headers: @auth_headers
    @mda.reload
    assert_equal orig_count + 1, @mda.disciplines.count

    mm = @mda.disciplines.last.meta_model
    put api_v1_meta_model_url(mm), params: { meta_model: {
        format: "matrix", values: [[3], [6]]
      } }, as: :json, headers: @auth_headers
    assert_response :success
  end

  test "should import a sub-analysis" do
    orig_count = @mda.disciplines.count
    mda2 = analyses(:outermda)
    disc = disciplines(:outermda_innermda_discipline)
    put api_v1_mda_url(@mda), params: {analysis: {import: {analysis: mda2.id, disciplines: [disc.id]}}}, 
      as: :json, headers: @auth_headers
    @mda.reload
    assert_equal orig_count + 1, @mda.disciplines.count
  end

  test "should recreate analysis with imports" do
    post api_v1_mdas_url, params: { analysis: { name: "Test" } }, as: :json, headers: @auth_headers
    assert_response :success
    mda = Analysis.last
    ids = @mda.disciplines.nodes.map(&:id)
    put api_v1_mda_url(mda), params: {analysis: {import: {analysis: @mda.id, disciplines: ids}}}, 
        as: :json, headers: @auth_headers
    assert_response :success
    assert_equal @mda.disciplines.count, mda.disciplines.count
    assert_equal @mda.disciplines.map(&:name), mda.disciplines.map(&:name)
    @mda.disciplines.each_with_index do |disc, i|
      varsInNewDisc = mda.disciplines[i].variables.map(&:name)
      disc.variables.map(&:name).each do |name|
        assert_includes varsInNewDisc, name
      end
    end
  end

  test "should create a discipline without output variables when imported twice" do
    post api_v1_mdas_url, params: { analysis: { name: "Test" } }, as: :json, headers: @auth_headers
    assert_response :success
    mda = Analysis.last
    disc = @mda.disciplines.nodes.first
    put api_v1_mda_url(mda), params: {analysis: {import: {analysis: @mda.id, disciplines: [disc.id, disc.id, disc.id]}}}, 
        as: :json, headers: @auth_headers
    assert_response :success
    assert_equal 4, mda.disciplines.count
    assert_equal [disc.name, disc.name, disc.name], mda.disciplines.nodes.map(&:name)
    assert_equal [], Discipline.last.output_variables
    assert_equal disc.input_variables.map(&:name), Discipline.last.input_variables.map(&:name)
  end

  # test "analysis spec are immutable" do
  #   @user3 = users(:user3)
  #   @auth_headers = { "Authorization" => "Token " + @user3.api_key }
  #   @spec = analyses(:singleton_mm_spec)
  #   put api_v1_mda_url(@spec), params: { analysis: { name: "TestNewName" } }, as: :json, headers: @auth_headers
  #   assert_response :unauthorized 
  # end
end
