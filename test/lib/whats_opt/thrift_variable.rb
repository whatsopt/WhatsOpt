require 'test_helper'

class FakeThriftVariable < Struct.new(:name, :type, :shape, :io_mode, :units, :desc)
  include WhatsOpt::ThriftVariable
end

class ThriftVariableTest < ActiveSupport::TestCase
  
  def test_should_have_a_float_thrift_type
    @var = FakeOpenmdaoVariable.new('VAR2tesT', :Float, 1, :in, "m", "description")
    assert_equal 'Float', @var.thrift_type
  end

  def test_should_have_a_vector_thrift_type
    @var = FakeOpenmdaoVariable.new('VAR2tesT', :Integer, "(2,)", :in, "m", "description")
    assert_equal 'IVector', @var.thrift_type
  end
  
end 

