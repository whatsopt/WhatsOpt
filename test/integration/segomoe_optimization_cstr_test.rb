require 'test_helper'
require 'matrix'

class SegomoeOptimizationCstrTest < ActionDispatch::IntegrationTest

  setup do
    @user1 = users(:user1)
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
  end

  def teardown
    WhatsOpt::OptimizerProxy.shutdown_server
  end

  def optimize(fun, cstrs, maxiter, xlimits, cstr_specs, doe)
    post api_v1_optimizations_url,
    params: { optimization: { kind: "SEGOMOE",
                              xlimits: xlimits,
                              cstr_specs: cstr_specs,
                            }
            },
      as: :json, headers: @auth_headers
    assert_response :success

    resp = JSON.parse(response.body)
    assert_equal "SEGOMOE", resp['kind']
    optim_id = resp['id']

    y = doe.map{|x| [fun.call(x)]}
    c = cstrs.map{|g| Matrix[*doe.map{|x| [g.call(x)]}]}
    y = c.inject(Matrix[*y]){|acc, mc| acc.hstack(mc)}.to_a
    x = doe

    best = [Float::MAX, nil]
    for i in 1..maxiter do
      patch api_v1_optimization_url(optim_id),
        params: { optimization: { x: x, y: y}},
        as: :json, headers: @auth_headers
      assert_response :success
      resp = JSON.parse(response.body)
      x_suggested = resp['x_suggested']

      new_y = fun.call(x_suggested)
      new_g1 = cstrs[0].call(x_suggested)
      new_g2 = cstrs[1].call(x_suggested)

      x << x_suggested
      y << [new_y, new_g1, new_g2]
      
      if new_y < best[0] && new_g1 < 0 && new_g2 < 0
        best = [new_y, y.size-1]
      end
    end
    return best
  end

  test "optimize objective with constraints" do
    skip_if_parallel
    skip_if_segomoe_not_installed

    # g24 optimum y_opt = -5.5080 at x_opt =(2.3295, 3.1785)
    f = Proc.new do |x|
      x1 = x[0]
      x2 = x[1]
      -x1 -x2
    end

    g1 = Proc.new do |x|
      x1 = x[0]
      x2 = x[1]
      - 2.0 * x1 ** 4.0 + 8.0 * x1 ** 3.0 - 8.0 * x1 ** 2.0 + x2 - 2.0
    end

    g2 = Proc.new do |x|
      x1 = x[0]
      x2 = x[1]
      -4.0 * x1 ** 4.0 + 32.0 * x1 ** 3.0 - 88.0 * x1 ** 2.0 + 96.0 * x1 + x2 - 36.0
    end

    xlimits = [[0, 3], [0, 4]]
    doe = [[2.68530201, 1.36927969],
    [0.52431663, 3.46702106],
    [1.96923192, 3.16016358],
    [1.19953988, 1.87783283],
    [1.74449478, 0.69256039]]

    cstr_specs = [{'type': '<', 'bound': 0.0}, {'type': '<', 'bound': 0.0}]

    best = self.optimize(f, [g1, g2], 15, xlimits, cstr_specs, doe)

    miny = best[0]
    minx = doe[best[1]]

    assert_in_delta(-5.5080, miny, 1e-4)
    assert_in_delta(2.3295, minx[0], 1e-4)
    assert_in_delta(3.1785, minx[1], 1e-4)
  end

end
