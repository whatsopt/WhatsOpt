require 'test_helper'
require 'whats_opt/surrogate_server/surrogate_store_types'

class SurrogateProxyTest < ActiveSupport::TestCase

  def setup
    @surr_proxy = WhatsOpt::SurrogateProxy.new
  end

  def teardown
    @surr_proxy.destroy_surrogate
    WhatsOpt::SurrogateProxy.shutdown_server
  end

  test "should predict values" do
    xt = [[0.0], [1.0], [2.0], [3.0], [4.0]]
    yt = [0.0, 1.0, 1.5, 0.5, 1.0]
    surr_kind = WhatsOpt::SurrogateServer::SurrogateKind::KRIGING
    @surr_proxy.create_surrogate(surr_kind, xt, yt)
    values = @surr_proxy.predict_values([[1.0], [2.5]])
    assert_in_delta(1.0, values[0]) 
    assert_in_delta(0.983, values[1]) 
    @surr_proxy.destroy_surrogate
  end

  test "should check server presence" do 
    assert @surr_proxy.server_available?
  end

  test "should check server absence" do 
    teardown
    refute @surr_proxy.server_available?
  end

  test "should not start server" do 
    teardown
    refute @surr_proxy.server_available?
    @surr_proxy = WhatsOpt::SurrogateProxy.new(server_start: false)
    refute @surr_proxy.server_available?
  end

end