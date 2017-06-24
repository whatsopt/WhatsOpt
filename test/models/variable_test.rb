require 'test_helper'

class VariableTest < ActiveSupport::TestCase
  
  test "should have dim and type default attributes" do
    assert Variable.new(name: 'test', io_mode: Variable::IN)
  end

end
