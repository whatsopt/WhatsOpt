# frozen_string_literal: true

require "test_helper"
require "whats_opt/package_extractor"
require "tmpdir"

class PackageExtractorTest < ActiveSupport::TestCase
  def setup
    @mda = analyses(:cicav)
    # XXX: Fixture does not seem to always load the file properly
    #      this ensure the presence of the file
    @mda.package.archive.attach(io: File.open(file_fixture('cicav-0.1.0.tar.gz')), filename: 'cicav-0.1.0.tar.gz',
                                content_type: 'application/gzip')
    assert @mda.package.archive.attached?
    assert File.exist?(ActiveStorage::Blob.service.path_for(@mda.package.archive.key))
    @pkgext = WhatsOpt::PackageExtractor.new(@mda)
  end

  test "should extract package" do
    Dir.mktmpdir do |dir|
      @genfiles = @pkgext.extract(dir)
      assert File.exist?(File.join(dir, "pyproject.toml"))
      assert File.exist?(File.join(dir, "README.md"))
      assert File.exist?(File.join(dir, "cicav"))
      expected = ["README.md", "cicav/__init__.py", "cicav/aerodynamics.py", "cicav/aerodynamics_base.py",
                  "cicav/cicav.py", "cicav/cicav_base.py", "cicav/geometry.py", "cicav/geometry_base.py",
                  "cicav/propulsion.py", "cicav/propulsion_base.py", "pyproject.toml"]
      assert_equal expected, @genfiles.map { |f| f[dir.size + 1..] }
    end
  end

  test "should extract source only from package" do
    Dir.mktmpdir do |dir|
      @genfiles = @pkgext.extract(dir, src_only: true)
      refute File.exist?(File.join(dir, "pyproject.toml"))
      refute File.exist?(File.join(dir, "README.md"))
      assert File.exist?(File.join(dir, "cicav"))
      expected = ["cicav/__init__.py", "cicav/aerodynamics.py", "cicav/aerodynamics_base.py",
                  "cicav/cicav.py", "cicav/cicav_base.py", "cicav/geometry.py", "cicav/geometry_base.py",
                  "cicav/propulsion.py", "cicav/propulsion_base.py"]
      assert_equal expected, @genfiles.map { |f| f[dir.size + 1..] }
    end
  end
end
