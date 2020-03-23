require 'test_helper'
require 'matrix'

class OptimizeAckley2D < ActionDispatch::IntegrationTest

  setup do
    @user1 = users(:user1)
    @auth_headers = { "Authorization" => "Token " + TEST_API_KEY }
  end

  def teardown
    WhatsOpt::OptimizerProxy.shutdown_server
  end

  def ackley2d(x)
    """
    Fonction Ackley 2D:
    1 global optimum value = 0 located at (0,0) 
    https://www.sfu.ca/~ssurjano/ackley.html
    """ 
    x1 = x[0]
    x2 = x[1]
    part_1 = -0.2*Math.sqrt(0.5*(x1*x1 + x2*x2))
    part_2 = 0.5*(Math.cos(2*Math::PI*x1) + Math.cos(2*Math::PI*x2))
    value = Math.exp(1) + 20 -20*Math.exp(part_1) - Math.exp(part_2)

    return value
  end

  test "optimize ackley2d" do
    skip_if_parallel
    skip_if_segomoe_not_installed

    post api_v1_optimizations_url,
      params: { optimization: { kind: "SEGOMOE",
                                xlimits: [[-3, 3], [-2, 2]],
                            }
                },
        as: :json, headers: @auth_headers
    assert_response :success

    resp = JSON.parse(response.body)
    assert_equal "SEGOMOE", resp['kind']
    optim_id = resp['id']
 

    doe = [[ 12.40589395, -15.81447117],
           [-18.67928515, -29.93869924],
           [-23.91062462,   5.0347297 ],
           [ 24.60309692,   8.79743867],
           [ -1.54756028,  25.96816089]]
    y = doe.map{|x| [ackley2d(x)]}
    x = doe

    best = y.map{|r| r[0]}.each_with_index.min 

    for i in 1..30 do
      patch api_v1_optimization_url(optim_id),
        params: { optimization: { x: x, y: y}},
        as: :json, headers: @auth_headers
      assert_response :success
      resp = JSON.parse(response.body)
      x_suggested = resp['x_suggested']
      new_y = ackley2d(x_suggested)
      x << x_suggested
      y << [new_y]

      if new_y < best[0]
        best = [new_y, y.size-1]
      end
      #p best
    end

    miny = best[0]
    minx = x[best[1]]
    #puts "Minimum y = #{miny} in x = #{minx} (iter=#{best[1]})"
    # assert close to minimum y=0 in x=[0,0] 
    assert_in_delta(0, miny, 1)
    assert_in_delta(0, minx[0], 0.5)
    assert_in_delta(0, minx[1], 0.5)
  end

end
