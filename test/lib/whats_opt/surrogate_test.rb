require 'test_helper'
require 'whats_opt/surrogate_server/surrogate_types'

class SurrogateTest < ActiveSupport::TestCase

  test "should predict values" do
    @surr_proxy = WhatsOpt::SurrogateProxy.new("s1")

    xt = [[0.0], [1.0], [2.0], [3.0], [4.0]]
    yt = [0.0, 1.0, 1.5, 0.5, 1.0]
    surr_kind = WhatsOpt::SurrogateServer::SurrogateKind::KRIGING
    @surr_proxy.create_surrogate(surr_kind, xt, yt)
    values = @surr_proxy.predict_values([[1.0], [2.5]])
    assert_in_delta(1.0, values[0]) 
    assert_in_delta(0.983, values[1]) 
    @surr_proxy.destroy_surrogate()
  end

end