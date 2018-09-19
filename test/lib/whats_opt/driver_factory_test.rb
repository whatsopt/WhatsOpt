require 'test_helper'

class DriverFactoryTest < ActiveSupport::TestCase
  
  def setup
    @option_hash = {
      smt_doe_lhs_nbpts: 100
    }
  end
  
  test "should create driver from valid option hash" do
    @driver = WhatsOpt::DriverFactory.new(@option_hash).create_driver
    assert_equal("smt_doe", @driver.lib)
    assert_equal("lhs", @driver.algo)
    assert_equal({nbpts: "100"}, @driver.options)
  end 
  
  test "should have a scipy slsqp as default driver" do
    @driver = WhatsOpt::DriverFactory.new({}).create_driver
    assert_equal("scipy_optimizer", @driver.lib)
    assert_equal("slsqp", @driver.algo)
    assert_equal({tol: "1.0e-06", maxiter: "100", disp: "True"}, @driver.options)    
  end

  test "should reject bad-formed option hash" do
    assert_raises WhatsOpt::DriverFactory::BadOptionError do
      WhatsOpt::DriverFactory.new({scipy_optimizer_slsqp_tol: 1e-3, smt_doe_lhs_nbpts: 5})
    end
  end

  test "should reject bad-formed option" do
    assert_raises WhatsOpt::DriverFactory::BadOptionError do
      WhatsOpt::DriverFactory.new({dummyoption: 1})
    end
  end
  
  test "should have default options for a given algorithm" do
    WhatsOpt::DriverFactory.new({scipy_optimizer_slsqp_tol: 1e-6})
  end
  
end
