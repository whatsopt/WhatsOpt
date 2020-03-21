# frozen_string_literal: true

require "test_helper"
require "matrix"

class OptimizerProxyTest < ActiveSupport::TestCase
  def setup
    @proxy = WhatsOpt::OptimizerProxy.new
  end

  def teardown
    @proxy.destroy_optimizer
    WhatsOpt::OptimizerProxy.shutdown_server
  end

  test "should tell and ask" do
    skip_if_parallel
    kind = WhatsOpt::Services::OptimizerKind::SEGOMOE
    @proxy.create_optimizer(kind, {xlimits: [[-32.768, 32.768], [-32.768, 32.768]]})
    x = [[0.1005624023, 0.1763338461],
         [0.843746558, 0.6787895599],
         [0.3861691997, 0.106018846]]
    y = [[9.09955542], [6.38231049], [12.4677347]]

    @proxy.tell(x, y)
    res = @proxy.ask()

    @proxy.destroy_optimizer
  end

  test "should check server presence" do
    skip_if_parallel
    sleep 2
    assert @proxy.server_available?
  end

  test "should check server absence" do
    skip_if_parallel
    teardown
    sleep 1
    assert_not @proxy.server_available?
  end

  test "should not start server" do
    WhatsOpt::OptimizerProxy.shutdown_server
    sleep 1
    assert_not @proxy.server_available?
    @proxy = WhatsOpt::OptimizerProxy.new(server_start: false)
    sleep 1
    assert_not @proxy.server_available?
  end
end
