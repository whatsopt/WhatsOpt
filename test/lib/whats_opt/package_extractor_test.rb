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
        @genfiles = @pkgext.extract(dir)
        assert File.exist?(File.join(dir, "setup.py"))
        assert File.exist?(File.join(dir, "README"))
        assert File.exist?(File.join(dir, "cicav"))
        expected = ["README", "cicav/__init__.py", "cicav/aerodynamics.py", "cicav/aerodynamics_base.py", 
                    "cicav/cicav.py", "cicav/cicav_base.py", "cicav/geometry.py", "cicav/geometry_base.py", 
                    "cicav/propulsion.py", "cicav/propulsion_base.py", "setup.py"]
        assert_equal expected, @genfiles.map{|f| f[dir.size+1..]}
    end
  end
end