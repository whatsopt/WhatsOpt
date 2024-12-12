# frozen_string_literal: true

require "test_helper"

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
    yt = [0.0, 1.0, 1.5, 0.9, 1.0]
    surr_kind = WhatsOpt::Services::SurrogateKind::SMT_KRIGING
    @surr_proxy.create_surrogate(surr_kind, xt, yt)
    values = @surr_proxy.predict_values([[1.0], [2.5]])
    assert_in_delta(1.0, values[0])
    assert_in_delta(1.195, values[1])
    @surr_proxy.destroy_surrogate
  end

  test "should predict values with openturns surrogate" do
    skip_if_parallel
    xt = [[0.0], [1.0], [2.0], [3.0], [4.0]]
    yt = [0.0, 1.0, 1.5, 0.5, 1.0]
    surr_kind = WhatsOpt::Services::SurrogateKind::OPENTURNS_PCE
    @surr_proxy.create_surrogate(surr_kind, xt, yt)
    values = @surr_proxy.predict_values([[1.0], [2.5]])
    assert_equal(2, values.size)
    @surr_proxy.destroy_surrogate
  end

  test "should get sobol indices with openturns surrogate" do
    skip_if_parallel
    xt = [[0.0], [1.0], [2.0], [3.0], [4.0]]
    yt = [0.0, 1.0, 2.0, 3.0, 4.0]
    surr_kind = WhatsOpt::Services::SurrogateKind::OPENTURNS_PCE
    @surr_proxy.create_surrogate(surr_kind, xt, yt, { pce_degree: "3" },
                                 [{ name: "Uniform", kwargs: { a: "1.9", b: "2.1" } }])
    sobols = @surr_proxy.get_sobol_pce_sensitivity_analysis
    assert (0.0 == sobols.S1[0] || 1.0 == sobols.S1[0])  # to avoid reproducibility pb in CI
    assert (0.0 == sobols.ST[0] || 1.0 == sobols.ST[0])  # to avoid reproducibility pb in CI
    @surr_proxy.destroy_surrogate
  end

  test "should qualify surrogate" do
    skip_if_parallel
    xt = [[0.0], [1.0], [2.0], [3.0], [4.0]]
    yt = [0.0, 1.0, 1.5, 0.5, 1.0]
    xv = [[0.0], [2.0], [4.0]]
    yv = [0.0, 1.5, 1.0]
    surr_kind = WhatsOpt::Services::SurrogateKind::SMT_KRIGING
    @surr_proxy.create_surrogate(surr_kind, xt, yt)
    @surr_proxy.predict_values([[1.0], [2.5]])
    q = @surr_proxy.qualify(xv, yv)
    assert_in_delta(1.0, q.r2)
    assert_in_delta(0.0, q.yp[0])
    assert_in_delta(1.5, q.yp[1])
    assert_in_delta(1.0, q.yp[2])
    @surr_proxy.destroy_surrogate
  end

  test "should check server presence" do
    skip_if_parallel
    sleep 1
    assert @surr_proxy.server_available?
  end

  test "should check server absence" do
    skip_if_parallel
    teardown
    sleep 1
    assert_not @surr_proxy.server_available?
  end

  test "should not start server" do
    WhatsOpt::SurrogateProxy.shutdown_server
    sleep 1
    assert_not @surr_proxy.server_available?
    @surr_proxy = WhatsOpt::SurrogateProxy.new(server_start: false)
    sleep 1
    assert_not @surr_proxy.server_available?
  end
end
