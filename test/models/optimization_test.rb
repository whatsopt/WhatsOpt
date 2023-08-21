# frozen_string_literal: true

require "test_helper"

class OperationTest < ActiveSupport::TestCase
  test "should create valid optim" do
    optim = Optimization.new(kind: "SEGOMOE", xlimits: [[0, 1], [0, 1]])
    assert optim.valid?
  end

  test "should reject bad optimizer kind" do
    optim = Optimization.new(kind: "TOTO", xlimits: [[0, 1], [0, 1]])
    assert_not optim.valid?
  end

  test "should reject bad xlimits" do
    optim = Optimization.new(kind: "SEGOMOE", xlimits: [])
    assert_not optim.valid?
  end

  test "should reject without xlimits" do
    optim = Optimization.new(kind: "SEGOMOE")
    assert_not optim.valid?
  end

  test "should retrieve config information" do
    optim = optimizations(:optim_ackley2d)
    assert_equal optim.config, { "xlimits" => [[-32.768, 32.768], [-32.768, 32.768]], "options" => {}, "n_obj" => 1, "cstr_specs" => [], "xtypes" => [] }
  end
end
