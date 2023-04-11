# frozen_string_literal: true

require "test_helper"
require "whats_opt/package_extractor"
require "tmpdir"

class PackageExtractorTest < ActiveSupport::TestCase
  def setup
    @mda = analyses(:cicav)
    @pkgext = WhatsOpt::PackageExtractor.new(@mda)
    assert @mda.package.archive.attached?
  end

  test "should extract package" do
    Dir.mktmpdir do |dir|
        @pkgext.extract(dir)
        assert File.exist?(File.join(dir, "setup.py"))
        assert File.exist?(File.join(dir, "README"))
        assert File.exist?(File.join(dir, "cicav"))
    end
  end
end