require 'test_helper'

class Api::V1::AnalysesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user1 = users(:user1)
    @auth_headers = {"Authorization" => "Token " + TEST_API_KEY}
    @mda = analyses(:cicav)
    @mda2 = analyses(:fast)
    @disc = @mda.disciplines.nodes.first
  end
  
  test "should get mdas" do
    get api_v1_mdas_url, as: :json, headers: @auth_headers
    assert_response :success
  end
  
  test "should create a mda" do
    post api_v1_mdas_url, params: { analysis: { name: "TestMda" } }, as: :json, headers: @auth_headers
    assert_response :success
  end

  test "should create sellar mda" do
    mda_params = {'analysis': {'name': 'Sellar', 'disciplines_attributes': [{'name': '__DRIVER__', 'variables_attributes': [{'name': 'x', 'io_mode': 'out', 'type': 'Float', 'shape': '1', 'units': nil, 'desc': '', 'parameter_attributes': {'init': '2.0'}}, {'name': 'z', 'io_mode': 'out', 'type': 'Float', 'shape': '(2,)', 'units': nil, 'desc': '', 'parameter_attributes': {'init': '[5.0, 2.0]'}}, {'name': 'obj', 'io_mode': 'in', 'type': 'Float', 'shape': '1', 'units': nil, 'desc': ''}, {'name': 'g1', 'io_mode': 'in', 'type': 'Float', 'shape': '1', 'units': nil, 'desc': 'constraint'}, {'name': 'g2', 'io_mode': 'in', 'type': 'Float', 'shape': '1', 'units': nil, 'desc': ''}]}, {'name': 'Disc1', 'variables_attributes': [{'name': 'x', 'io_mode': 'in', 'type': 'Float', 'shape': '1', 'units': nil, 'desc': ''}, {'name': 'y2', 'io_mode': 'in', 'type': 'Float', 'shape': '1', 'units': nil, 'desc': ''}, {'name': 'z', 'io_mode': 'in', 'type': 'Float', 'shape': '(2,)', 'units': nil, 'desc': ''}, {'name': 'y1', 'io_mode': 'out', 'type': 'Float', 'shape': '1', 'units': nil, 'desc': ''}]}, {'name': 'Disc2', 'variables_attributes': [{'name': 'y2', 'io_mode': 'out', 'type': 'Float', 'shape': '1', 'units': nil, 'desc': ''}, {'name': 'y1', 'io_mode': 'in', 'type': 'Float', 'shape': '1', 'units': nil, 'desc': ''}, {'name': 'z', 'io_mode': 'in', 'type': 'Float', 'shape': '(2,)', 'units': nil, 'desc': ''}]}, {'name': 'Functions', 'variables_attributes': [{'name': 'x', 'io_mode': 'in', 'type': 'Float', 'shape': '1', 'units': nil, 'desc': ''}, {'name': 'y1', 'io_mode': 'in', 'type': 'Float', 'shape': '1', 'units': nil, 'desc': ''}, {'name': 'y2', 'io_mode': 'in', 'type': 'Float', 'shape': '1', 'units': nil, 'desc': ''}, {'name': 'z', 'io_mode': 'in', 'type': 'Float', 'shape': '(2,)', 'units': nil, 'desc': ''}, {'name': 'obj', 'io_mode': 'out', 'type': 'Float', 'shape': '1', 'units': nil, 'desc': ''}, {'name': 'g1', 'io_mode': 'out', 'type': 'Float', 'shape': '1', 'units': nil, 'desc': 'constraint'}, {'name': 'g2', 'io_mode': 'out', 'type': 'Float', 'shape': '1', 'units': nil, 'desc': ''}]}]}}
    post api_v1_mdas_url, params: mda_params, as: :json, headers: @auth_headers
    assert_response :success
    analysis = Analysis.last
    analysis.driver.output_variables.each do |v| 
      case v.name
      when 'x'
        assert_equal '2.0', v.parameter.init
      when 'z'
        assert_equal '[5.0, 2.0]', v.parameter.init
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
    assert_equal 'TestNewName', resp['name'] 
  end  
  
  test "should update a mda with attachment" do
    @mda.build_attachment()
    @mda.attachment.data = sample_file("excel_mda_dummy.xlsx")
    @mda.save!
    put api_v1_mda_url(@mda), params: { analysis: { name: "TestNewName" } }, as: :json, headers: @auth_headers
    assert_response :success
    get api_v1_mda_url(@mda), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal 'TestNewName', resp['name'] 
  end  

  test "should get xdsm format" do
    get api_v1_mda_url(@mda, :format => 'xdsm'), as: :json, headers: @auth_headers
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal @mda.disciplines.count, resp['nodes'].size
  end

  test "should create nested analysis" do
    assert_difference('Discipline.count', 4) do
      assert_difference('Analysis.count', 2) do
      mda_attrs = 
        {"name": "Outer", "disciplines_attributes": [
          {"name": "__DRIVER__", "variables_attributes": [
            {"name": "x", "io_mode": "out", "type": "Float", "shape": "1", "units": "", "desc": "",
                  "parameter_attributes": {"init": "2.0"}}, 
            {"name": "y", "io_mode": "in", "type": "Float", "shape": "1", "units": ""}]}, 
          {"name": "InnerDiscipline", "sub_analysis_attributes":  
            {"name": "MyInner", "disciplines_attributes": [
              {"name": "__DRIVER__", "variables_attributes": [
                  {"name": "x", "io_mode": "out", "type": "Float", "shape": "1", "units": "",  "desc": "",
                      "parameter_attributes": {"init": "2.0"}}, 
                  {"name": "y", "io_mode": "in", "type": "Float", "shape": "1", "units": "",  "desc": ""}]},
              {"name": "Disc", "variables_attributes": [
                {"name": "x", "io_mode": "in", "type": "Float", "shape": "1", "units": "",  "desc": "",
                  "parameter_attributes": {"init": "2.0"}},
                {"name": "y", "io_mode": "out", "type": "Float", "shape": "1", "units": "",  "desc": ""}
              ]}
            ]}
          }
        ]}
      post api_v1_mdas_url, params: {analysis: mda_attrs}, as: :json, headers: @auth_headers
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
    mda_params = {analysis: JSON.load(sample_file("sellar_optim.json"))}
    post api_v1_mdas_url, params: mda_params, as: :json, headers: @auth_headers
    inner = Analysis.find_by_name('Sellar')
    outer = Analysis.find_by_name('SellarOptim')
    assert_equal outer.id, inner.parent.id
    assert_equal @user1, outer.owner
    assert_equal @user1, inner.owner
  end

  test "should update descendants attributes" do
    @outer = analyses(:outermda)
    public = true
    patch api_v1_mda_url(@outer), params: {analysis: {public: public}}, as: :json, headers: @auth_headers
    @inner = analyses(:innermda)
    assert_equal public, @inner.public
    public = false
    patch api_v1_mda_url(@outer), params: {analysis: {public: public}}, as: :json, headers: @auth_headers
    assert_equal public, @inner.reload.public
  end
    
  test "should have an openmdao implementation in mda_viewer json" do
    mdajson = JSON.parse(@mda.to_mda_viewer_json)
    assert_equal({"name"=>"NonlinearBlockGS", "atol"=>1.0e-06, "rtol"=>1.0e-10, 
                  "maxiter"=>7, "err_on_maxiter"=>true, "iprint"=>2}, mdajson['impl']['openmdao']['nonlinear_solver']) 
    assert_equal({"name"=>"ScipyKrylov", "atol"=>1.0e-08, "rtol"=>1.0e-07, 
                  "maxiter"=>10, "err_on_maxiter"=>false, "iprint"=>1}, mdajson['impl']['openmdao']['linear_solver'])
    assert_equal false, mdajson['impl']['openmdao']['components']['parallel_group']
    assert 3, mdajson['impl']['openmdao']['components']['nodes'].size
  end
end
