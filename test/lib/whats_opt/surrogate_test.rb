require 'test_helper'
require 'whats_opt/surrogate_server/surrogate_types'

class SurrogateTest < ActiveSupport::TestCase

  def setup
    @surr_proxy = WhatsOpt::SurrogateProxy.new("s1")
  end

  test "should contact the surrogate server" do
    xt = [[0.0], [1.0], [2.0], [3.0], [4.0]]
    yt = [0.0, 1.0, 1.5, 0.5, 1.0]
    surr_kind = WhatsOpt::SurrogateServer::SurrogateKind::KRIGING
    @surr_proxy.create_surrogate(surr_kind, xt, yt)
  end

  test "should predict" do
    print(@surr_proxy.predict_values([[1.0], [2.5]]))
  end

end