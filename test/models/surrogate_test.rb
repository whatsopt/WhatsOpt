require 'test_helper'

class SurrogateTest < ActiveSupport::TestCase

  setup do
    @surr = surrogates(:surrogate_obj)
    @surr_file = File.join(WhatsOpt::SurrogateProxy::OUTDIR, "surrogate_#{@surr.id}.pkl")
  end

  teardown do
    WhatsOpt::SurrogateProxy.shutdown_server
  end

  test "should be train and predict" do
    skip_if_parallel
    assert_equal Surrogate::STATUS_CREATED, @surr.status
    @surr.train
    assert File.exists?(@surr_file)
    @surr.reload
    assert_equal Surrogate::STATUS_TRAINED, @surr.status 
    assert_in_delta(2.35, @surr.predict([[3.3, 2, 7]]).first)
    assert_in_delta(6.012, @surr.predict([[3.3, 2, 7], [5, 4, 3]]).second)
  end
  
end
