require 'test_helper'

class FakeOpenmdaoVariable < Struct.new(:name, :type, :shape, :io_mode, :units, :desc)
  include WhatsOpt::OpenmdaoVariable
end

class OpenmdaoMappingTest < ActiveSupport::TestCase
  
  def test_should_have_a_description
    @var = FakeOpenmdaoVariable.new('VAR2tesT', :Float, 1, :in, "m", "description")
    assert_equal 'description (m)', @var.py_desc
  end

end 

