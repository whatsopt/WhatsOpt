# frozen_string_literal: true

require "test_helper"

class OperationTest < ActiveSupport::TestCase
  test "should create valid optim" do
    optim = Optimization.new(kind: "SEGOMOE", xlimits: [[0, 1], [0, 1]])
    assert optim.valid?
  end

  test "should reject bad optimizer kind" do
    assert_raises Optimization::ConfigurationInvalid do 
      optim = Optimization.new(kind: "TOTO", xlimits: [[0, 1], [0, 1]])
      p optim
    end
  end

  test "should reject bad xlimits" do
    assert_raises Optimization::ConfigurationInvalid do 
      optim = Optimization.new(kind: "SEGOMOE", xlimits: [])
    end
  end

  test "should reject without xlimits" do
    assert_raises Optimization::ConfigurationInvalid do 
      optim = Optimization.new(kind: "SEGOMOE")
    end
  end

end
