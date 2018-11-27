require 'test_helper'

class ConnectionTest < ActiveSupport::TestCase
 
  def setup
    @mda = analyses(:cicav)
  end
  
  test "should create connections from an mda" do
    assert_difference('Connection.count', 7) do
      Connection.create_connections(@mda)
    end
  end 
  
  test "should get edges" do
    refute_empty @mda.build_edges
  end
  
  test "should have a role" do
    conns = Connection.joins(from: :discipline).where(disciplines: {analysis_id: @mda.id})
    assert_equal ["design_var", "min_objective", 
                  "parameter", "parameter", "response", 
                  "state_var", "state_var"], conns.map(&:role).sort
  end
  
  test "should update init parameter without changing other attrs" do
    conn = Connection.of_analysis(@mda).with_role(WhatsOpt::Variable::DESIGN_VAR_ROLE).take
    assert_equal "3.14", conn.from.parameter.init
    assert_equal "1", conn.from.parameter.lower
    conn.update_variables!({parameter_attributes: {init: "2"}})
    conn.reload
    assert_equal "2", conn.from.parameter.init
    conn.update_variables!({parameter_attributes: {init: ""}})
    conn.reload
    assert_equal "1", conn.from.parameter.lower
  end

  test "should delete parameter when init, lower and upper are blank" do
    conn = Connection.of_analysis(@mda).with_role(WhatsOpt::Variable::DESIGN_VAR_ROLE).take
    assert_equal "3.14", conn.from.parameter.init
    conn.update_variables!({parameter_attributes: {lower: "", upper: ""}})
    assert conn.from.parameter
    conn.update_variables!({parameter_attributes: {init: ""}})
    conn.from.reload
    assert_nil conn.from.parameter
  end 
end
