# frozen_string_literal: true

require "test_helper"

class OpenmdaoAnalysisImplTest < ActiveSupport::TestCase
  setup do
    @oai = openmdao_analysis_impls(:openmdao_cicav_impl)
  end

  test "should provide default solver configuration" do
    oai = OpenmdaoAnalysisImpl.new(analysis: analyses(:cicav))
    assert_equal "NonlinearBlockGS", oai.nonlinear_solver.name
    assert_equal "ScipyKrylov",  oai.linear_solver.name
    assert_equal false, oai.parallel_group
  end

  test "should update parallel flag" do
    @oai.update_impl({ parallel_group: true, use_units: true })
    @oai.reload
    assert_not @oai.parallel_group.nil?
    assert @oai.parallel_group
    assert_not @oai.use_units.nil?
    assert @oai.use_units
    @oai.update_impl({ parallel_group: false, use_units: false })
    @oai.reload
    assert_not @oai.parallel_group
    assert_not @oai.use_units
  end

  test "should update solver" do
    @oai.update_impl(nonlinear_solver: { name: "NonlinearBlockJac" })
    assert_equal "NonlinearBlockJac", @oai.nonlinear_solver.name
    assert_equal 1e-06, @oai.nonlinear_solver.atol
  end

  test "should have json with nodes" do
    assert ActiveModelSerializers::SerializableResource.new(@oai).as_json[:nodes]
  end
end
