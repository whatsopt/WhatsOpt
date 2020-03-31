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

    best = y.map{|r| r[0]}.each_with_index.min     
    for i in 1..maxiter do
      patch api_v1_optimization_url(optim_id),
        params: { optimization: { x: x, y: y}},
        as: :json, headers: @auth_headers
      assert_response :success
      resp = JSON.parse(response.body)
      x_suggested = resp['x_suggested']
      p x_suggested

      new_y = fun.call(x_suggested)
      new_g1 = cstrs[0].call(x_suggested)
      new_g2 = cstrs[1].call(x_suggested)

      x << x_suggested
      y << [new_y, new_g1, new_g2]
      p [new_y, new_g1, new_g2]
      

      if new_y < best[0]
        best = [new_y, y.size-1]
        p "BEST >>>>>>>>>>>>", best
      end
    end
    return best
  end

  test "optimize objective with constraints" do
    skip_if_parallel
    skip_if_segomoe_not_installed

    f = Proc.new do |x|
      x1 = x[0]
      x2 = x[1]
      (x1 - 10)**3 + (x2 - 20)**3
    end

    g1 = Proc.new do |x|
      x1 = x[0]
      x2 = x[1]
      100 - (x1 - 5)**2 + (x2 - 5)**2
    end

    g2 = Proc.new do |x|
      x1 = x[0]
      x2 = x[1]
      -82.81 - (x1 - 6)**2 - (x2 - 5)**2
    end

    xlimits = [[13, 100], [0, 100]]
    doe = [[4.53499546e+01, 9.75638651e+01],
    [2.19317979e+01, 5.06639542e+01],
    [9.14044229e+01, 6.66791422e+01],
    [3.91243199e+01, 3.39599723e+01],
    [9.93010211e+01, 4.24993151e+01],
    [7.38845917e+01, 5.79569747e+01],
    [2.61545999e+01, 1.67974231e+01],
    [1.80074580e+01, 9.31662066e+01],
    [6.53608287e+01, 8.19638829e+01],
    [6.29155169e+01, 3.28400442e+01],
    [3.28796292e+01, 7.35977150e+01],
    [8.73111169e+01, 2.43234459e+01],
    [7.98480444e+01, 4.80361987e-02],
    [5.40602817e+01, 7.57325973e+00],
    [5.02982664e+01, 6.39518204e+01]]

    cstr_specs = [{'type': '<', 'bound': 0.0}, {'type': '<', 'bound': 0.0}]

    best = self.optimize(f, [g1, g2], 5, xlimits, cstr_specs, doe)

    miny = best[0]
    minx = doe[best[1]]

    p "RESULT ", minx, miny
    #assert_in_delta(−6961.8, miny, 0.1)
    # assert_in_delta(0, minx[0], 0.5)
    # assert_in_delta(0, minx[1], 0.5)
  end

end
