# frozen_string_literal: true

require "test_helper"

class ParameterTest < ActiveSupport::TestCase

  setup do
    @var = variables(:varx1_out)
  end

  test "could be a float" do
    p = Parameter.new(variable: @var, init: 1e2, lower: 3, upper: 4.4)
    assert p.valid?
  end

  test "could be an array" do
    p = Parameter.new(variable: @var, init: [3, 2], lower: [1e2, 4.5], upper: [2.5e4, 5])
    assert p.valid?
  end

  test "could be nan" do
    p = Parameter.new(variable: @var, init: "nan")
    assert p.valid?
  end

end