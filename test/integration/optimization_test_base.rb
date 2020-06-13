require "test_helper"
require "matrix"

class OptimizationTestBase < ActionDispatch::IntegrationTest
  setup do
    # Bug: https://github.com/rails/rails/issues/37270 : test_adapter overrides backgroundjob runner
    (ActiveJob::Base.descendants << ActiveJob::Base).each(&:disable_test_adapter)
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
    assert_equal "SEGOMOE", resp["kind"]
    optim_id = resp["id"]

    y = doe.map { |x| [fun.call(x)] }
    c = cstrs.map { |g| Matrix[*doe.map { |x| [g.call(x)] }] }
    y = c.inject(Matrix[*y]) { |acc, mc| acc.hstack(mc) }.to_a
    x = doe

    best = [Float::MAX, nil]
    for i in 1..maxiter do
      patch api_v1_optimization_url(optim_id),
        params: { optimization: { x: x, y: y } }, as: :json, headers: @auth_headers
      assert_response :success

      try = 30
      x_suggested = nil
      while try > 0 && !x_suggested do
        get api_v1_optimization_url(optim_id), as: :json, headers: @auth_headers
        assert_response :success
        resp = JSON.parse(response.body)
        status = resp["outputs"]["status"]
        if status != Optimization::RUNNING
          x_suggested = resp["outputs"]["x_suggested"]
        end
        sleep(1)
        try = try-1
      end
      if try <= 0
        raise "Can not get x suggestion"
      end

      new_y = [fun.call(x_suggested)]
      cstrs.each do |cstr|
        new_y << cstr.call(x_suggested)
      end
      x << x_suggested
      y << new_y

      neg_cstr = new_y.size == 1 || new_y[1..-1].inject(true) { |acc, g| acc && g < 0 }
      if new_y[0] < best[0] && neg_cstr
        best = [new_y[0], y.size-1]
      end
    end
    best
  end
end
