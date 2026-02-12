# frozen_string_literal: true

require "test_helper"

class FakeOpenmdaoVariable < Struct.new(:name, :type, :shape, :io_mode, :units, :desc)
  include WhatsOpt::OpenmdaoVariable
end

class OpenmdaoMappingTest < ActiveSupport::TestCase
  def test_should_have_a_description_escaped
    @var = FakeOpenmdaoVariable.new("VAR2tesT", WhatsOpt::Variable::FLOAT_T, "1", :in, "m", "description")
    assert_equal "description (m)", @var.escaped_desc
  end
  def test_should_have_a_description_with_unit
    @var = FakeOpenmdaoVariable.new("VAR2tesT", WhatsOpt::Variable::FLOAT_T, "1", :in, "m", "'description'")
    assert_equal "\\'description\\' (m)", @var.escaped_desc
  end

  def test_should_have_a_description_without_unit
    @var = FakeOpenmdaoVariable.new("VAR2tesT", WhatsOpt::Variable::FLOAT_T, "1", :in, "", "description")
    assert_equal "description", @var.extended_desc
  end

  def test_should_have_no_description
    @var = FakeOpenmdaoVariable.new("VAR2tesT", WhatsOpt::Variable::FLOAT_T, "1", :in, "N", "")
    assert_equal "", @var.extended_desc
  end

  def test_default_py_value
    @var = FakeOpenmdaoVariable.new("VAR2tesT", WhatsOpt::Variable::FLOAT_T, "1", :in, "m", "description")
    assert_equal "1.0", @var.default_py_value
    assert_equal "1.0", @var.default_py_value(true)
    @var = FakeOpenmdaoVariable.new("VAR2tesT", WhatsOpt::Variable::INTEGER_T, "1", :in, "m", "description")
    assert_equal "1", @var.default_py_value
    assert_equal "1", @var.default_py_value(true)
    @var = FakeOpenmdaoVariable.new("VAR2tesT", WhatsOpt::Variable::INTEGER_T, "(2,)", :in, "m", "description")
    assert_equal "np.ones((2,), dtype=np.int32)", @var.default_py_value
    assert_equal "jnp.ones((2,), dtype=jnp.int32)", @var.default_py_value(true)
  end

  def test_ones_py_value
    @var = FakeOpenmdaoVariable.new("VAR2tesT", WhatsOpt::Variable::FLOAT_T, "(2,)", :in, "m", "description")
    assert_equal "np.ones((2,))", @var.ones_py_value
    assert_equal "jnp.ones((2,))", @var.ones_py_value(true)
  end
end
