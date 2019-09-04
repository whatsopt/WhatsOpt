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
    skip_if_parallel
    xt = [[0.0], [1.0], [2.0], [3.0], [4.0]]
    yt = [0.0, 1.0, 1.5, 0.5, 1.0]
    surr_kind = WhatsOpt::SurrogateServer::SurrogateKind::KRIGING
    @surr_proxy.create_surrogate(surr_kind, xt, yt)
    values = @surr_proxy.predict_values([[1.0], [2.5]])
    assert_in_delta(1.0, values[0]) 
    assert_in_delta(0.983, values[1]) 
    @surr_proxy.destroy_surrogate
  end

  test "should qualify surrogate" do
    skip_if_parallel
    xt = [[0.0], [1.0], [2.0], [3.0], [4.0]]
    yt = [0.0, 1.0, 1.5, 0.5, 1.0]
    xv = [[0.0], [2.0], [4.0]]
    yv = [0.0, 1.5, 1.0]
    surr_kind = WhatsOpt::SurrogateServer::SurrogateKind::KRIGING
    @surr_proxy.create_surrogate(surr_kind, xt, yt)
    values = @surr_proxy.predict_values([[1.0], [2.5]])
    q = @surr_proxy.qualify(xv, yv)
    assert_in_delta(1.0, q.r2) 
    assert_in_delta(0.0, q.yp[0]) 
    assert_in_delta(1.5, q.yp[1]) 
    assert_in_delta(1.0, q.yp[2]) 
    @surr_proxy.destroy_surrogate
  end 

  test "should check server presence" do
    skip_if_parallel
    assert @surr_proxy.server_available?
  end

  test "should check server absence" do 
    skip_if_parallel
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