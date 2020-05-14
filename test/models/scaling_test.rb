# frozen_string_literal: true

require "test_helper"

class ScalingTest < ActiveSupport::TestCase

  setup do
    @var = variables(:varx1_out)
  end

  test "could be a float" do
    s = Scaling.new(variable: @var, ref: 1e2, ref0: 3, res_ref: 4.4)
    assert s.valid?
  end

  test "could be an array" do
    s = Scaling.new(variable: @var, ref: [3, 2], ref0: [1e2, 4.5], res_ref: [2.5e4, 5])
    assert s.valid?
  end

  test "could not be nan" do
    s = Scaling.new(variable: @var, ref: "nan")
    assert_not s.valid?
  end
end
