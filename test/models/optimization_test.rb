# frozen_string_literal: true

require "test_helper"
require "fileutils"

class OperationTest < ActiveSupport::TestCase
  test "should create valid optim" do
    optim = Optimization.new(kind: "SEGOMOE", xlimits: [[0, 1], [0, 1]])
    assert optim.valid?
  end

  test "should reject bad optimizer kind" do
    optim = Optimization.new(kind: "TOTO", xlimits: [[0, 1], [0, 1]])
    assert !optim.valid?
  end

  test "should reject bad xlimits" do
    optim = Optimization.new(kind: "SEGOMOE", xlimits: [])
    assert !optim.valid?
  end

  test "should reject without xlimits" do
    optim = Optimization.new(kind: "SEGOMOE")
    assert !optim.valid?
  end
end
