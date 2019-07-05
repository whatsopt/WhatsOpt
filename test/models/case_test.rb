# frozen_string_literal: true

require "test_helper"

class CaseTest < ActiveSupport::TestCase
  def test_as_json
    cas = cases(:case1)
    adapter = ActiveModelSerializers::SerializableResource.new(cas)
    expected = { values: [1, 2, 3], varname: "x1", coord_index: -1 }
    assert_equal expected, adapter.as_json
  end

  def test_scope
    ope = operations(:doe)
    assert_equal [cases(:case1), cases(:case3), cases(:case4)], ope.input_cases
    assert_equal [cases(:case2)], ope.output_cases
  end
end
