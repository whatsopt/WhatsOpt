require 'test_helper'

class OpenmdaoAnalysisImplTest < ActiveSupport::TestCase

  setup do
    @oai = openmdao_analysis_impls(:openmdao_cicav_impl)
  end

  test "should provide default solver configuration" do
    oai = OpenmdaoAnalysisImpl.new
    assert_equal "NonlinearBlockGS", oai.nonlinear_solver.name
    assert_equal "ScipyKrylov",  oai.linear_solver.name
    assert_equal false, oai.parallel_group
  end

  test "should update parallel flag" do
    @oai.update_impl(parallel_group: true)
    refute @oai.parallel_group.nil?
    assert @oai.parallel_group
    @oai.update_impl(parallel_group: false)
    refute @oai.parallel_group
  end

  test "should update solver" do
    @oai.update_impl(nonlinear_solver: {name: "NonlinearBlockJac"})
    assert_equal "NonlinearBlockJac", @oai.nonlinear_solver.name
    assert_equal 1e-06, @oai.nonlinear_solver.atol
  end
end
