require 'test_helper'

class FakeOpenmdaoModule < Struct.new(:name)
  include WhatsOpt::OpenmdaoModule
end

class OpenmdaoMappingTest < ActiveSupport::TestCase
  
  def test_should_have_a_valid_py_classname_even_with_space_in_name
    @module = FakeOpenmdaoModule.new('PRF CICAV')
    assert_equal 'PrfCicav', @module.py_classname
  end
  
  def test_should_have_a_valid_py_modulename
    @module = FakeOpenmdaoModule.new('PRF CICAV')
    assert_equal 'prf_cicav', @module.py_modulename
  end

end 

