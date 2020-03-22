# frozen_string_literal: true

require "test_helper"

class SurrogateTest < ActiveSupport::TestCase
  setup do
    @surr = surrogates(:surrogate_obj)
    @surr_file = File.join(WhatsOpt::ServiceProxy::OUTDIR, "surrogate_#{@surr.id}.pkl")
  end

  teardown do
    WhatsOpt::SurrogateProxy.shutdown_server
  end

  test "should be train and predict" do
    skip_if_parallel
    assert_equal Surrogate::STATUS_CREATED, @surr.status
    @surr.train
    sleep 1
    assert File.exist?(@surr_file)
    @surr.reload
    assert_equal Surrogate::STATUS_TRAINED, @surr.status
    assert_in_delta(2.502, @surr.predict([[3.3, 2, 7]]).first, 1)
    assert_in_delta(6.034, @surr.predict([[3.3, 2, 7], [5, 4, 3]]).second, 1)
  end

  test "should be train and predict with options" do
    skip_if_parallel
    assert_equal Surrogate::STATUS_CREATED, @surr.status
    @surr.train
    assert File.exist?(@surr_file)
    @surr.reload
    assert_equal Surrogate::STATUS_TRAINED, @surr.status
    assert_in_delta(2.502, @surr.predict([[3.3, 2, 7]]).first, 1)
    assert_in_delta(6.034, @surr.predict([[3.3, 2, 7], [5, 4, 3]]).second, 1)
  end

  test "should be copied and prediction with copy get same results" do
    skip_if_parallel
    assert_equal Surrogate::STATUS_CREATED, @surr.status
    @surr.train
    @surr.reload
    assert_equal Surrogate::STATUS_TRAINED, @surr.status
    assert_difference('Option.count', 1) do
      copy = @surr.build_copy
      copy.save!
      assert_equal copy.options.count, @surr.options.count
      assert_equal Surrogate::STATUS_CREATED, copy.status
      assert_in_delta(2.502, copy.predict([[3.3, 2, 7]]).first, 1)
      assert_in_delta(6.034, copy.predict([[3.3, 2, 7], [5, 4, 3]]).second, 1)
      assert_equal Surrogate::STATUS_TRAINED, copy.reload.status
    end
  end

  test "extract at indices" do
    skip_if_parallel
    xt, xv = @surr._extract_at_indices([1, 2, 3, 4, 5], [1, 3])
    assert_equal [1, 3, 5], xt
    assert_equal [2, 4], xv
  end

  test "should compute qualification" do
    skip_if_parallel
    @surr = surrogates(:surrogate_obj2)
    assert_equal Surrogate::STATUS_CREATED, @surr.status
    @surr.train # use one point for testing out of 10 points of the doe
    @surr.reload
    assert_equal Surrogate::STATUS_TRAINED, @surr.status
    assert_in_delta(1.0, @surr.r2)
    assert_equal (50-1)/10+1, @surr.xvalid.size
    assert_equal (50-1)/10+1, @surr.yvalid.size
    assert_equal (50-1)/10+1, @surr.ypred.size
    @surr.train(test_part: 15)  # use one point for testing out of 15 points of the doe
    @surr.reload
    assert_equal Surrogate::STATUS_TRAINED, @surr.status
    assert_in_delta(1.0, @surr.r2)

    assert_equal (50-1)/15+1, @surr.xvalid.size
    assert_equal (50-1)/15+1, @surr.yvalid.size
    assert_equal (50-1)/15+1, @surr.ypred.size
  end

  test "should remove surrogate without deleting variables" do
    skip_if_parallel
    var = @surr.variable
    @surr.destroy!
    assert @surr.variable
  end
end
