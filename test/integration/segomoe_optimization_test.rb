# frozen_string_literal: true

require "integration/optimization_test_base"

class SegomoeOptimization < OptimizationTestBase
  test "optimize sixhump" do
    skip_if_parallel
    skip_if_segomoe_not_installed
    skip "a bit long to run"

    sixhump = Proc.new do |x|
      """
      Function Six-Hump Camel Back
      2 global optimum value =-1.0316 located at (0.089842, -0.712656) and  (-0.089842, 0.712656)
      https://www.sfu.ca/~ssurjano/camel6.html

      """
      x1 = x[0]
      x2 = x[1]
      4 * x1**2 - 2.1 * x1**4 + 1.0 / 3.0 * x1**6 + x1 * x2 - 4 * x2**2 + 4 * x2**4
    end

    xlimits = [[-3, 3], [-2, 2]]
    doe = [[ 0.66996854,  0.35232979],
    [-0.1483595,   1.61924086],
    [ 2.34130933, -1.05001473],
    [-2.40777823,  0.84365121],
    [-0.78322913, -1.82952567]]

    best = self.optimize(sixhump, [], 30, xlimits, [], doe)

    miny = best[0]
    # minx = doe[best[1]]
    assert_in_delta(-1.013, miny, 0.1)
    # assert_in_delta(0, minx[0], 0.5)
    # assert_in_delta(0, minx[1], 0.5)
  end

  test "optimize ackley2d" do
    skip_if_parallel
    skip_if_segomoe_not_installed
    skip "used only for second validation"
    ackley2d = Proc.new do |x|
      """
      Fonction Ackley 2D:
      1 global optimum value = 0 located at (0,0)
      https://www.sfu.ca/~ssurjano/ackley.html
      """
      x1 = x[0]
      x2 = x[1]
      part_1 = -0.2 * Math.sqrt(0.5 * (x1 * x1 + x2 * x2))
      part_2 = 0.5 * (Math.cos(2 * Math::PI * x1) + Math.cos(2 * Math::PI * x2))
      Math.exp(1) + 20 - 20 * Math.exp(part_1) - Math.exp(part_2)
    end

    xlimits = [[-32.768, 32.768], [-32.768, 32.768]]
    doe = [[ 12.40589395, -15.81447117],
           [-18.67928515, -29.93869924],
           [-23.91062462,   5.0347297 ],
           [ 24.60309692,   8.79743867],
           [ -1.54756028,  25.96816089]]

    best = self.optimize(ackley2d, [], 2, xlimits, [], doe)

    miny = best[0]
    minx = doe[best[1]]
    assert_in_delta(0, miny, 1)
    assert_in_delta(0, minx[0], 0.5)
    assert_in_delta(0, minx[1], 0.5)
  end
end
