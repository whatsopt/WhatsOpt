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

  test "operation may have options" do
    ope = operations(:doe)
    assert_equal "smt_doe_lhs_nbpts", ope.options.first.name
  end

  test "operations has success infos" do
    ope = operations(:doe)
    assert ope.success
  end

  test "should create a ope doe copy using given destination analysis and variable names" do
    ope = operations(:doe)
    copy_mda = ope.analysis.create_copy!
    varnames = ["x1", "obj"]
    copy_ope = ope.create_copy!(copy_mda, varnames)
    # z is of shape (2,), hence 2 cases z[0] z[1] are removed
    assert_equal ope.cases.size - 2, copy_ope.cases.size
    assert_equal varnames.sort, (ope.cases.map { |c| c.variable.name } - ["z", "z"]).sort
  end
end
