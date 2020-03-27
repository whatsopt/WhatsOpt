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

  def optimize(fun, cstrs, maxiter, xlimits, doe)
    post api_v1_optimizations_url,
    params: { optimization: { kind: "SEGOMOE",
                              xlimits: xlimits,
                          }
              },
      as: :json, headers: @auth_headers
    assert_response :success

    resp = JSON.parse(response.body)
    assert_equal "SEGOMOE", resp['kind']
    optim_id = resp['id']

    y = doe.map{|x| [fun.call(x)]}
    p y

    c = cstrs.map{|g| Matrix[*doe.map{|x| [g.call(x)]}]}
    p c
    y = c.inject(Matrix[*y]){|acc, mc| acc.hstack(mc)}.to_a
    x = doe
    p x
    p y
    return 0
    # return
    # best = y.map{|r| r[0]}.each_with_index.min     
    # for i in 1..maxiter do
    #   patch api_v1_optimization_url(optim_id),
    #     params: { optimization: { x: x, y: y}},
    #     as: :json, headers: @auth_headers
    #   assert_response :success
    #   resp = JSON.parse(response.body)
    #   x_suggested = resp['x_suggested']
    #   new_y = fun.call(x_suggested)

    #   x << x_suggested
    #   y << [new_y]

    #   if new_y < best[0]
    #     best = [new_y, y.size-1]
    #   end
    # end
    # return best
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
    doe = [[87.25431706, 42.97541219],
    [58.91660449, 84.92674764],
    [76.59066297,  8.6717486 ],
    [26.31798431, 60.33050887],
    [38.17109146, 24.71604597]]

    best = self.optimize(f, [g1, g2], 30, xlimits, doe)

    miny = best[0]
    minx = doe[best[1]]
    #assert_in_delta(−6961.8, miny, 0.1)
    # assert_in_delta(0, minx[0], 0.5)
    # assert_in_delta(0, minx[1], 0.5)
  end

end
