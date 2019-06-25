require 'test_helper'
#require 'whats_opt/variable'

class VariableTest < ActiveSupport::TestCase
  
  test "should get attributes from cases attributes" do
    cases = [{"varname": 'x1', "coord_index": -1, "values": [10, 20, 30]}, 
             {"varname": 'obj', "coord_index": 0, "values": [40, 50, 60]},
             {"varname": 'obj', "coord_index": 1, "values": [40, 50, 60]}]
    var_attrs = Variable.get_variables_attributes(cases)
    assert_equal 2, var_attrs.size
    assert_equal ["x1", "obj"], var_attrs.map{|v| v[:name]}

    x1 = var_attrs.find {|v| v[:name] == 'x1'}
    assert_equal WhatsOpt::Variable::IN, x1[:io_mode]
    assert_equal '1', x1[:shape]
    obj = var_attrs.find {|v| v[:name] == 'obj'}
    assert_equal WhatsOpt::Variable::OUT, obj[:io_mode]
    assert_equal '(2,)', obj[:shape]
  end
end