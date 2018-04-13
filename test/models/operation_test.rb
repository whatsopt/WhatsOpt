require 'test_helper'

class OperationTest < ActiveSupport::TestCase
  def test_as_json
    ope = operations(:doe)
    adapter = ActiveModelSerializers::SerializableResource.new(ope)
    assert ope.as_json
  end
end