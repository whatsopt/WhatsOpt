require 'test_helper'
require 'whats_opt/openmdao_mapping'

class FakeOpenmdaoModule < Struct.new(:name)
  include WhatsOpt::OpenmdaoModule
end

class FakeOpenmdaoVariable < Struct.new(:name, :type, :shape, :io_mode, :units, :desc)
  include WhatsOpt::OpenmdaoVariable
end

class OpenmdaoMappingTest < ActiveSupport::TestCase
  
  def test_should_have_a_valid_py_classname_even_with_space_in_name
    @module = FakeOpenmdaoModule.new('PRF CICAV')
    assert_equal 'PrfCicav', @module.py_classname
  end

  def test_should_have_a_valid_py_varname
    @var = FakeOpenmdaoVariable.new('VAR2tesT')
    assert_equal 'var2test', @var.py_varname
  end

end 

