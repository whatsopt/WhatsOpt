require 'test_helper'

class CaseTest < ActiveSupport::TestCase
  def test_as_json
    cas = cases(:case1)
    adapter = ActiveModelSerializers::SerializableResource.new(cas)
    expected = {:values=>[1, 2, 3], :varname=>"x1"}
    assert_equal expected, adapter.as_json    
  end
end
