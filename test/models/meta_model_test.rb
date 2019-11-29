# frozen_string_literal: true

require "test_helper"

class MetaModelTest < ActiveSupport::TestCase
  setup do
    @mm = meta_models(:cicav_metamodel)
    @mm2 = meta_models(:cicav_metamodel2)
    @varobj = variables(:disc_metamodel_varobj_objective_out)
  end

  teardown do
    WhatsOpt::SurrogateProxy.shutdown_server
  end

  test "should have training input values" do
    assert_equal [[1.0, 8, 5], [2.5, 3, 4], [5, 6, 3], [7.5, 9, 2], [9.8, 10, 1]], @mm.training_input_values
  end

  test "should have training output values for a varname and a coord" do
    assert_equal [4, 5, 6, 7, 8], @mm.training_output_values(@varobj.name, -1)
  end

  test "should predict" do
    skip_if_parallel
    x = [[1.0, 8, 5], [8, 9, 10], [5, 4, 3]]
    y = @mm.predict(x)
    assert_in_delta 4, y[0][0]
    assert_equal x.size, y.size
  end

  test "should predict with a copy" do
    skip_if_parallel
    x = [[1.0, 8, 5], [8, 9, 10], [5, 4, 3]]
    mm = @mm.build_copy
    mm.save!
    y = mm.predict(x)
    assert_in_delta 4, y[0][0]
    assert_equal x.size, y.size
  end

  test "should raise exception if x invalid" do
    x = [[1.0, 8], [8, 9, 10], [5, 4, 3]]
    assert_raises MetaModel::PredictionError do
      @mm.predict(x)
    end
  end

  test "should be qualified" do
    assert_equal 1, @mm2.qualification.size
    assert_equal [:kind, :name, :r2, :xvalid, :ypred, :yvalid], @mm2.qualification[0].keys.sort
    assert_in_delta(1.0, @mm2.qualification[0][:r2])
  end
end
