# frozen_string_literal: true

require "test_helper"

class OperationTest < ActiveSupport::TestCase
  def test_as_json
    ope = operations(:doe)
    adapter = ActiveModelSerializers::SerializableResource.new(ope)
    assert ope.as_json
  end

  def test_operations_in_progress_with_no_case
    mda = analyses(:cicav)
    ope = Operation.in_progress(mda).take
    assert_equal [], ope.success
    assert_equal operations(:inprogress).id, ope.id
  end

  def test_operations_has_success_infos
    ope = operations(:doe)
    assert ope.success
  end
end
