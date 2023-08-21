# frozen_string_literal: true

require "test_helper"

class PackageTest < ActiveSupport::TestCase
  def setup
    @pkg = packages(:cicav_pkg)
  end

  test "should have a name" do
    assert_equal "cicav", @pkg.name
  end

  test "should have a version" do
    assert_equal "0.1.0", @pkg.version
  end

  test "should update when package archive change" do
    assert @pkg.archive.attached?
    date = @pkg.updated_at
    @pkg.archive.attach(io: File.open(file_fixture("cicav-0.1.0.tar.gz")), filename: "cicav-0.1.0.tar.gz",
                        content_type: "application/gzip")
    assert @pkg.archive.attached?
    @pkg.save!
    assert_not_equal date, @pkg.updated_at
  end
end
