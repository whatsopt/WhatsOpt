# frozen_string_literal: true

require "test_helper"

class PackahgeTest < ActiveSupport::TestCase

  def setup
    @pkg = packages(:cicav_pkg)
  end

  test "should have a name" do
    assert_equal "cicav", @pkg.name
  end

  test "should have a version" do
    assert_equal "0.1.0", @pkg.version
  end

end