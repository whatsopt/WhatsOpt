# frozen_string_literal: true

require "test_helper"

class FakeOpenmdaoModule < Struct.new(:name)
  include WhatsOpt::OpenmdaoModule
end

class OpenmdaoMappingTest < ActiveSupport::TestCase
  setup do
    @module = FakeOpenmdaoModule.new("PRF CICAV")
    @module.unset_root_module
  end

  test "should have a valid py classname even with space in name" do
    assert_equal "PrfCicav", @module.py_classname
  end

  test "should have a valid py modulename" do
    assert_equal "prf_cicav", @module.py_modulename
  end

  test "should modify modulename regarding root_modulename" do
    @outer = analyses(:outermda)
    assert_equal "outerpkg", @outer.py_full_modulename
    @outer_disc = disciplines(:outermda_discipline)
    assert_equal "disc", @outer_disc.impl.py_full_modulename
    @inner = analyses(:innermda)
    assert_equal "inner.inner", @inner.py_full_modulename
    @inner_disc = disciplines(:innermda_discipline)
    assert_equal "inner.plain_discipline", @inner_disc.impl.py_full_modulename
    @outer.set_as_root_module
    assert_equal "outerpkg", @outer.py_full_modulename
    assert_equal "inner.inner", @inner.py_full_modulename
    assert_equal "inner.plain_discipline", @inner_disc.impl.py_full_modulename
    @inner.set_as_root_module
    assert_equal "outerpkg", @outer.py_full_modulename
    assert_equal "inner", @inner.py_full_modulename
    assert_equal "plain_discipline", @inner_disc.impl.py_full_modulename
  end

  test "should have a snake module name" do
    @inner_disc = disciplines(:innermda_discipline)
    assert_equal "inner_plain_discipline", @inner_disc.impl.snake_modulename
  end

  test "should have a camel module name" do
    @inner_disc = disciplines(:innermda_discipline)
    assert_equal "InnerPlainDiscipline", @inner_disc.impl.camel_modulename
  end
end
