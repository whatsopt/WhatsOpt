require 'test_helper'

class ConnectionTest < ActiveSupport::TestCase
 
  test "should create connections from an mda" do
    mda = analyses(:cicav)
    assert_difference('Connection.count', 7) do
      Connection.create_connections(mda)
    end
  end 
  
  test "should get edges" do
    mda = analyses(:cicav)
    mda.build_edges
  end
  
  test "migration" do
    mda = analyses(:cicav)
    conns = Connection.joins(from: :discipline).where(disciplines: {analysis_id: mda.id})
  end
  
end
