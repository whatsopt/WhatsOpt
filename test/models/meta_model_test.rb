require 'test_helper'

class MetaModelTest < ActiveSupport::TestCase

  setup do
    @mm = meta_models(:cicav_metamodel)
    @varobj = variables(:disc_metamodel_varobj_objective_out)
  end

  test "should have training input values" do
    assert_equal [[1.0, 8, 5], [2.5, 3, 4], [5, 6, 3], [7.5, 9, 2], [9.8, 10, 1]], @mm.training_input_values
  end

  test "should have training output values for a varname and a coord" do
    assert_equal [4, 5, 6, 7, 8], @mm.training_output_values(@varobj.name, -1)
  end
end
