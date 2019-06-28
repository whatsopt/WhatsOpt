# frozen_string_literal: true

require "test_helper"

class FakeThriftVariable < Struct.new(:name, :type, :shape, :io_mode, :units, :desc)
  include WhatsOpt::ThriftVariable
end

class ThriftVariableTest < ActiveSupport::TestCase
  test "should manage names with colons" do
    @var = FakeThriftVariable.new("geometry:wing")
    assert_equal "geometry__COLON__wing", @var.thrift_name
  end

  test "should manage names with hyphens" do
    @var = FakeThriftVariable.new("geometry-wing")
    assert_equal "geometry__HYPHEN__wing", @var.thrift_name
  end

  test "should have a float thrift type" do
    @var = FakeThriftVariable.new("VAR2tesT", "Float", "1", :in, "m", "description")
    assert_equal "Float", @var.thrift_type
  end

  test "should have a vector thrift type" do
    @var = FakeThriftVariable.new("VAR2tesT", "Integer", "(2,)", :in, "m", "description")
    assert_equal "IVector", @var.thrift_type
  end
end
