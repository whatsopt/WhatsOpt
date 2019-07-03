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
    expected = [{:name=>"z", :io_mode=>:"in", :shape=>"1", :type=>"Float", :desc=>nil, :units=>nil, :active=>true, :parameter=>{:init=>"3.14", :lower=>"1", :upper=>"10"}, :scaling=>nil}, {:name=>"x1", :io_mode=>:"in", :shape=>"1", :type=>"Float", :desc=>nil, :units=>nil, :active=>true, :parameter=>{:init=>"3.14", :lower=>"1", :upper=>"10"}, :scaling=>nil}, {:name=>"obj", :io_mode=>"out", :shape=>"1", :type=>"Float", :desc=>nil, :units=>nil, :active=>true, :parameter=>nil, :scaling=>nil}]
    assert_equal expected, varattrs
  end
end
