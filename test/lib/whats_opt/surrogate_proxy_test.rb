require 'test_helper'
require 'whats_opt/surrogate_server/surrogate_store_types'

class SurrogateProxyTest < ActiveSupport::TestCase

  PYTHON = APP_CONFIG["python_cmd"] || "python"

  def setup
    @pid = spawn("#{PYTHON} #{File.join(Rails.root, 'surrogate_server', 'run_surrogate_server.py')}", [:out] => "/dev/null")
    sleep(2) # startup time
  end

  def teardown
    Process.kill("TERM", @pid)
    Process.waitpid @pid
  end

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