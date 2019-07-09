require 'test_helper'

class SurrogateTest < ActiveSupport::TestCase

  setup do
    @surr = surrogates(:surrogate_obj)
  end

  test "should be trained" do
    assert_equal Surrogate::STATUS_CREATED, @surr.status
    @surr.train
    assert_equal Surrogate::STATUS_TRAINED, @surr.status 
  end
  
end
