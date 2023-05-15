# frozen_string_literal: true

require "test_helper"
require "whats_opt/package_extractor"
require "tmpdir"

class PackageFetcherTest < ActiveSupport::TestCase
  def setup
    @mda = analyses(:cicav)  
    @src_mda = analyses(:singleton)  
    # XXX: Fixture does not seem to always load the file properly
    #      this ensure the presence of the file
    @mda.package.archive.attach(io: File.open(file_fixture('cicav-0.1.0.tar.gz')), filename: 'cicav-0.1.0.tar.gz',
                                content_type: 'application/gzip')
    assert @mda.package.archive.attached?
    assert File.exist?(ActiveStorage::Blob.service.path_for(@mda.package.archive.key))

    @src_mda.package.archive.attach(io: File.open(file_fixture('singleton-0.1.0.tar.gz')), filename: 'singleton-0.1.0.tar.gz',
                                content_type: 'application/gzip')
    assert @src_mda.package.archive.attached?
    assert File.exist?(ActiveStorage::Blob.service.path_for(@src_mda.package.archive.key))

    @pkgfetcher = WhatsOpt::PackageFetcher.new(@mda, @src_mda)
  end

  test "should generate source" do
    Dir.mktmpdir do |dir|
        @genfiles = @pkgfetcher._generate_code(dir)
        expected = ["cicav/__init__.py", "cicav/singleton_discipline.py", "cicav/singleton_discipline_base.py"]
        assert_equal expected, @genfiles.map{|f| f[dir.size+1..]}
    end
  end
end