# frozen_string_literal: true

require "csv"

if ENV["WHATSOPT_COVERALLS"]
  require "simplecov"
end

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"

TEST_API_KEY = "FriendlyApiKey"

PYTHON = APP_CONFIG["python_cmd"] || "python"

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

  def csv2hash(filename)
    res = {}
    CSV.foreach("test/fixtures/#{filename}", headers: true, col_sep: ";", converters: :float).with_index(1) do |row, ln|
      if ln == 1
        row.headers.each { |h| res[h] = [] }
      end
      row.each { |h, elt| res[h] << elt }
    end
    res
  end
end

# XXX: Dirty monkeypatching as flock used by shakapacker prevents from running test on erebe due to
# ActionView::Template::Error: Bad file descriptor @ rb_file_flock - /d/rlafage/workspace/WhatsOpt/tmp/shakapacker.lock
# Problem seems to be related to flock / NFS interaction
if `hostname`.include?('erebe')
  class File
    def flock(_p)
      # FIXME 
      # p "Warning: flock call disabled on erebe! (see test_helper.rb)"
    end
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
