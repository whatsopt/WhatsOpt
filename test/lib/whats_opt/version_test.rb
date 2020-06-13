# frozen_string_literal: true

require "test_helper"

class VersionTest < ActiveSupport::TestCase
  include WhatsOpt::Version

  test "should success" do
    assert_not check_wop_minimal_version(Gem::Version.new(WOP_MINIMAL_VERSION).bump())
  end

  test "should fail" do
    assert_raise WopVersionMismatchException do
      check_wop_minimal_version("1.3.6")
    end
  end

  test "should fail with release candidate" do
    assert_raise WopVersionMismatchException do
      check_wop_minimal_version("1.2.0rc2")
    end
  end
end
