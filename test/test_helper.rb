# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def sample_file(filename = "sample_file.png")
    File.new("test/fixtures/#{filename}")
  end

  parallelize(workers: 1)

  def skip_if_parallel
    skip "when run in parallel" if ENV["PARALLEL_WORKERS"].to_i > 1
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  #  # Make the Capybara DSL available in all integration tests
  #  include Capybara::DSL
  #  # Make `assert_*` methods behave like Minitest assertions
  #  include Capybara::Minitest::Assertions
  #
  #  # Reset sessions and driver between tests
  #  # Use super wherever this method is redefined in your individual test classes
  #  def teardown
  #    Capybara.reset_sessions!
  #    Capybara.use_default_driver
  #  end
end

TEST_API_KEY = "FriendlyApiKey"
