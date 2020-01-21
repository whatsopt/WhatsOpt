# frozen_string_literal: true

require "test_helper"

class Api::V1::ConnectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }

    @mda = analyses(:cicav)
    @geometry = disciplines(:geometry)
    @aerodynamics = disciplines(:aerodynamics)
    @propulsion = disciplines(:propulsion)
    @varyg = variables(:varyg_geo_out)
    @conn = connections(:geo_yg_aero)
    @varzout = variables(:varz_design_out)

    @outermda = analyses(:outermda)
    @outermdadisc = disciplines(:outermda_discipline)
    @innermda = analyses(:innermda)
    @innermdadisc = disciplines(:outermda_innermda_discipline)
    @vacantdisc = disciplines(:outermda_vacant_discipline)
  end

  test "should create a new connection and related variables" do
    assert_difference("Variable.count", 2) do
      assert_difference("Connection.count", 1) do
        post api_v1_mda_connections_url(mda_id: @mda.id,
                                         connection: { from: @geometry.id, to: @aerodynamics.id, names: ["newvar"] }),
             as: :json, headers: @auth_headers
        assert_response :success
      end
    end
    conn = Connection.last
    assert_equal WhatsOpt::Variable::STATE_VAR_ROLE, conn.role
  end

  test "should create no new connection if connection already exists" do
    assert_difference("Variable.count", 0) do
      assert_difference("Connection.count", 0) do
        post api_v1_mda_connections_url(mda_id: @mda.id,
                                         connection: { from: @geometry.id, to: @aerodynamics.id, names: [@varyg.name] }),
             as: :json, headers: @auth_headers
        assert_response :success
      end
    end
  end

  test "should create no new variable out if variable already exists" do
    assert_difference("Variable.count", 1) do
      assert_difference("Connection.count", 1) do
        post api_v1_mda_connections_url(mda_id: @mda.id,
                                         connection: { from: @geometry.id, to: @propulsion.id, names: [@varyg.name] }),
             as: :json, headers: @auth_headers
        assert_response :success
      end
    end
  end

  test "should create connection from same discipline to other ones" do
    post api_v1_mda_connections_url(mda_id: @mda.id,
                                     connection: { from: @geometry.id, to: @mda.driver.id, names: [@varyg.name] }),
         as: :json, headers: @auth_headers
    assert_response :success
  end

  test "should raise error on bad request" do
    post api_v1_mda_connections_url(mda_id: @mda.id,
                                     connection: { from: @geometry.id, to: @aerodynamics.id, names: [""] }),
         as: :json, headers: @auth_headers
    assert_match(/can't be blank/, JSON.parse(response.body)["message"])
    assert_response :unprocessable_entity
  end

  test "should delete a connection" do
    assert_difference("Variable.count", -2) do
      connyg = Connection.find_by_from_id(@varyg.id)
      delete api_v1_connection_url(connyg), as: :json, headers: @auth_headers
      assert_response :success
    end
  end

  test "should delete a connection but keep out variable if there is another connection" do
    connz = Connection.where(from_id: @varzout.id)
    assert_equal 2, connz.count
    connz1 = connz.first
    assert_difference("Variable.count", -1) do
      delete api_v1_connection_url(connz1), as: :json, headers: @auth_headers
      assert_response :success
    end
  end

  test "should update a connection" do
    _assert_connection_update(@conn, @conn)
  end

  test "should move a connection to an existing sub-discipline variable" do
    assert_difference("Variable.count", 0) do
      assert_difference("Connection.count", 0) do
        driver_out_count = @outermda.driver.output_variables.count
        disc_out_count = @outermdadisc.output_variables.count
        var_to_move = variables(:varx2_outermda_driver_out)
        post api_v1_mda_connections_url(
          mda_id: @outermda.id, connection: { from: @outermdadisc.id,
           to: @innermdadisc.id, names: [var_to_move.name] }), as: :json, headers: @auth_headers
        assert_response :success
        assert_equal(-1, @outermda.driver.output_variables.reload.count - driver_out_count)
        assert_equal 1, @outermdadisc.output_variables.reload.count - disc_out_count
      end
    end
  end

  test "should prevent connection creation to or from a non-existing sub-discipline variable" do
    assert_difference("Variable.count", 0) do
      assert_difference("Connection.count", 0) do
        post api_v1_mda_connections_url(mda_id: @outermda.id,
                                         connection: { from: @outermdadisc.id, to: @innermdadisc.id, names: ["unknown"] }),
             as: :json, headers: @auth_headers
        assert_response :unprocessable_entity
        post api_v1_mda_connections_url(mda_id: @outermda.id,
                                         connection: { from: @innermdadisc.id, to: @outermdadisc.id, names: ["unknown"] }),
             as: :json, headers: @auth_headers
        assert_response :unprocessable_entity
      end
    end
  end

  test "should remove a connection from a sub-analysis" do
    assert_difference("Variable.count", -1) do
      assert_difference("Connection.count", -1) do
        conn = connections(:innermda_disc_y2_outermda_disc)
        delete api_v1_connection_url(conn), as: :json, headers: @auth_headers
        assert_response :success
      end
    end
  end

  test "should re-connect to driver when removing a connection to a sub-analysis" do
    assert_difference("Variable.count", 0) do
      assert_difference("Connection.count", 0) do
        conn = connections(:outermda_disc_y1_innermda_disc)
        delete api_v1_connection_url(conn), as: :json, headers: @auth_headers
        assert_response :success
      end
    end
  end

  test "should prevent from removing a connection between driver and sub-analysis" do
    assert_difference("Variable.count", 0) do
      assert_difference("Connection.count", 0) do
        conn = connections(:innermda_disc_y_outermda_driver)
        delete api_v1_connection_url(conn), as: :json, headers: @auth_headers
        assert_response :unprocessable_entity
        assert_equal "Connection y has to be suppressed in InnerMdaDiscipline sub-analysis first",
                     JSON.parse(response.body)["message"]
        conn = connections(:outermda_driver_x2_innermda_disc)
        delete api_v1_connection_url(conn), as: :json, headers: @auth_headers
        assert_response :unprocessable_entity
        assert_equal "Connection x2 has to be suppressed in InnerMdaDiscipline sub-analysis first",
                     JSON.parse(response.body)["message"]
      end
    end
  end

  test "should create new connection in analysis ancestors when creating new driver connection in sub-analysis" do
    assert_difference("Variable.count", 4) do
      assert_difference("Connection.count", 2) do
        driver_out_count = @outermda.driver.output_variables.count
        disc_in_count = @innermdadisc.input_variables.count
        post api_v1_mda_connections_url(mda_id: @innermda.id,
                                         connection: { from: @innermda.driver.id, to: @innermda.disciplines.last.id, names: ["newvar"] }),
             as: :json, headers: @auth_headers
        assert_response :success
        assert_equal 1, @outermda.driver.output_variables.reload.count - driver_out_count
        assert_equal 1, @innermdadisc.input_variables.reload.count - disc_in_count
      end
    end
  end

  test "should reconnect in analysis ancestor when creating new driver connection in sub-analysis with existing variable" do
    assert_difference("Variable.count", 3) do
      assert_difference("Connection.count", 2) do
        driver_out_count = @outermda.driver.output_variables.count
        disc_in_count = @innermdadisc.input_variables.count
        post api_v1_mda_connections_url(mda_id: @innermda.id,
                                         connection: { from: @innermda.driver.id, to: @innermda.disciplines.last.id, names: ["x1"] }),
             as: :json, headers: @auth_headers
        assert_response :success
        assert_equal 0, @outermda.driver.output_variables.reload.count - driver_out_count
        assert_equal 1, @innermdadisc.input_variables.reload.count - disc_in_count
      end
    end
  end

  test "should reconnect input variable as state variable properly" do
    post api_v1_mda_disciplines_url(@mda), params: { discipline: { name: "test" } }, as: :json, headers: @auth_headers
    disc_test = Discipline.last
    disc_geo = disciplines(:geometry)
    post api_v1_mda_connections_url(@mda), params: { connection: { from: disc_test.id, to: disc_geo.id, names: ["x1"] } }, as: :json, headers: @auth_headers
    assert_not_includes @mda.parameter_variables.map(&:name), "x1"
  end

  test "should remove related y1 connections in ancestor when removing driverish connection in sub-analysis1" do
    assert_difference("Variable.count", -3) do
      assert_difference("Connection.count", -2) do
        conn = connections(:innermda_driver_y1_innermda_disc)
        delete api_v1_connection_url(conn), as: :json, headers: @auth_headers
        assert_response :success
      end
    end
  end

  test "should remove related y connection in ancestor when removing driverish connection in sub-analysis2" do
    assert_difference("Variable.count", -4) do
      assert_difference("Connection.count", -2) do
        conn = connections(:innermda_disc_y_innermda_driver)
        delete api_v1_connection_url(conn), as: :json, headers: @auth_headers
        assert_response :success
      end
    end
  end

  test "should propagate y connection update upward to ancestor" do
    conn = connections(:innermda_disc_y_innermda_driver)
    conn_to_test = connections(:innermda_disc_y_outermda_driver)
    self._assert_connection_update(conn, conn_to_test)
  end

  test "should propagate y connection update downward to sub-analysis" do
    conn = connections(:innermda_disc_y_outermda_driver)
    conn_to_test = connections(:innermda_disc_y_innermda_driver)
    self._assert_connection_update(conn, conn_to_test)
  end

  test "should propagate y1 connection update upward to ancestor" do
    conn = connections(:innermda_driver_y1_innermda_disc)
    conn_to_test = connections(:outermda_disc_y1_innermda_disc)
    self._assert_connection_update(conn, conn_to_test)
  end

  test "should propagate y1 connection update downward to sub-analysis" do
    conn = connections(:outermda_disc_y1_innermda_disc)
    conn_to_test = connections(:innermda_driver_y1_innermda_disc)
    self._assert_connection_update(conn, conn_to_test)
  end

  def _assert_connection_update(conn, conn_to_test)
    attrs = [:name, :type, :shape, :units, :desc, :active]
    values = ["test", "Integer", "(1,)", "m", "test description", false]
    update_attrs = attrs.zip(values).to_h
    update_attrs[:parameter_attributes] = { init: "[[1,2]]", lower: "0", upper: "10" }
    update_attrs[:scaling_attributes] = { ref: "[[1,2]]", ref0: "100", res_ref: "1e-6" }
    update_attrs[:distribution_attributes] = { kind: "Normal", 
                                               options_attributes: [{name: "mu", value: "0.0"}, {name: "sigma", value: "1.0"}] }
    put api_v1_connection_url(conn, connection: update_attrs), as: :json, headers: @auth_headers
    assert_response :success
    conn_to_test.reload
    conn_to_test.from.reload
    conn_to_test.to.reload
    attrs.each_with_index do |attr, i|
      assert_equal values[i], conn_to_test.from.send(attr)
      assert_equal values[i], conn_to_test.to.send(attr)
    end
    assert conn_to_test.from.parameter
    assert_equal "[[1,2]]", conn_to_test.from.parameter.init
    assert_equal "0", conn_to_test.from.parameter.lower
    assert_equal "10", conn_to_test.from.parameter.upper
    assert conn_to_test.from.parameter
    assert_equal "[[1,2]]", conn_to_test.from.scaling.ref
    assert_equal "100", conn_to_test.from.scaling.ref0
    assert_equal "1e-6", conn_to_test.from.scaling.res_ref
    assert_not conn_to_test.to.parameter
    assert_not conn_to_test.to.scaling
    assert_not conn_to_test.to.active
    assert_not conn_to_test.from.active
    assert_equal "Normal", conn_to_test.from.distribution.kind
    assert_equal "mu", conn_to_test.from.distribution.options.first.name
    assert_equal "0.0", conn_to_test.from.distribution.options.first.value
  end
end
