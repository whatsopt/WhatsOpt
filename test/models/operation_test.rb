# frozen_string_literal: true

require "test_helper"

class OperationTest < ActiveSupport::TestCase
  test "as json" do
    ope = operations(:doe)
    ActiveModelSerializers::SerializableResource.new(ope)
    assert ope.as_json
  end

  test "operations in progress with no case" do
    mda = analyses(:cicav)
    ope = Operation.in_progress(mda).take
    assert_equal [], ope.success
    assert_equal operations(:inprogress).id, ope.id
  end

  test "operations has success infos" do
    ope = operations(:doe)
    assert ope.success
  end

  test "should build varattrs from an operation" do
    ope = operations(:doe)
    varattrs = ope.build_metamodel_varattrs
    expected = [{ name: "obj", io_mode: :out, shape: "1", type: "Float", active: true, parameter_attributes: {}}, { name: "x1", io_mode: :in, shape: "1", type: "Float", active: true, parameter_attributes: { init: "3.14", lower: "1", upper: "10" } }, { name: "z", io_mode: :in, shape: "(2,)", type: "Float", active: true, parameter_attributes: { init: "3.14", lower: "1", upper: "10" }}]
    assert_equal expected, varattrs
  end
end
