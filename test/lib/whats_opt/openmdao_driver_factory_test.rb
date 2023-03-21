# frozen_string_literal: true

require "test_helper"

class OpenmdaoDriverFactoryTest < ActiveSupport::TestCase
  def setup
    @driver_name = :smt_doe_lhs
    @driver_options = { smt_doe_lhs_nbpts: 100 }
  end

  test "should create driver from valid option hash" do
    @driver = WhatsOpt::OpenmdaoDriverFactory.new(@driver_name, @driver_options).create_driver
    assert_equal("smt_doe", @driver.lib)
    assert_equal("lhs", @driver.algo)
    assert_equal({ nbpts: 100 }, @driver.options)
  end

  test "should have a scipy slsqp as default driver" do
    @driver = WhatsOpt::OpenmdaoDriverFactory.new().create_driver
    assert_equal("scipy_optimizer", @driver.lib)
    assert_equal("slsqp", @driver.algo)
    assert_equal({ tol: 1.0e-06, maxiter: 100, disp: "True" }, @driver.options)
  end

  test "should create segomoe driver" do
    @driver = WhatsOpt::OpenmdaoDriverFactory.new(:onerasego_optimizer_segomoe,
        onerasego_optimizer_segomoe_maxiter: 100,
        onerasego_optimizer_segomoe_ncluster: 2,
        onerasego_optimizer_segomoe_optimizer: "cobyla",
        onerasego_optimizer_segomoe_doedim: 10).create_driver
    assert_equal("onerasego_optimizer", @driver.lib)
    assert_equal("segomoe", @driver.algo)
    assert_equal({}, @driver.options)
    assert_equal({"maxiter"=>100, "n_clusters"=>2, "optimizer"=>"'cobyla'", "size_doe"=>10}, @driver.opt_settings)
  end

  test "should create an egor driver" do
    @driver = WhatsOpt::OpenmdaoDriverFactory.new(:egobox_optimizer_egor,
        egobox_optimizer_egor_n_clusters: 2,
        egobox_optimizer_egor_maxiter: 100,
    ).create_driver
    assert_equal("egobox_optimizer", @driver.lib)
    assert_equal("egor", @driver.algo)
    assert_equal({}, @driver.options)
    assert_equal({"n_clusters"=>2, "maxiter"=>100, "cstr_tol"=>0.0001, "infill_strategy"=>"egx.InfillStrategy.WB2", "infill_optimizer"=>"egx.InfillOptimizer.SLSQP", "regr_spec"=>"egx.RegressionSpec.CONSTANT", "corr_spec"=>"egx.CorrelationSpec.SQUARED_EXPONENTIAL"}, @driver.opt_settings)
  end

  test "should reject bad-formed option hash" do
    assert_raises WhatsOpt::OpenmdaoDriverFactory::BadOptionError do
      WhatsOpt::OpenmdaoDriverFactory.new(:scipy_optimizer_slsqp, scipy_optimizer_slsqp_tol: 1e-3, smt_doe_lhs_nbpts: 5)
    end
  end

  test "should reject bad-formed option" do
    assert_raises WhatsOpt::OpenmdaoDriverFactory::BadOptionError do
      WhatsOpt::OpenmdaoDriverFactory.new(:baddriver, dummyoption: 1)
    end
  end
end
