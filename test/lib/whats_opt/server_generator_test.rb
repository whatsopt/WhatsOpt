# frozen_string_literal: true

require "test_helper"
require "whats_opt/server_generator"
require "tmpdir"
require "pathname"
require "mkmf"

class ServerGeneratorTest < ActiveSupport::TestCase
  def thrift?
    @found ||= find_executable("thrift")
  end

  def setup
    @mda = analyses(:cicav)
    @sgen = WhatsOpt::ServerGenerator.new(@mda)
  end

  test "should generate server code for an analysis" do
    skip "Apache Thrift not installed" unless thrift?
    Dir.mktmpdir do |dir|
      filepath = @sgen._generate_code dir
      assert File.exist?(filepath)
    end
  end

  test "should use thrift command to generate thrift code" do
    skip "Apache Thrift not installed" unless thrift?
    Dir.mktmpdir do |dir|
      ok, _log = @sgen._generate_with_thrift(dir)
      assert ok
    end
  end

  test "should maintain a list of generated filepaths" do
    skip "Apache Thrift not installed" unless thrift?
    Dir.mktmpdir do |dir|
      @sgen._generate_code dir
      rootdir = Pathname.new(dir)
      filenames = @sgen.genfiles.map { |f| Pathname.new(f).relative_path_from(rootdir).to_s }.sort
      expected = ["run_server.py",
                  "server/__init__.py", "server/analysis.thrift", "server/cicav/__init__.py",
                  "server/cicav/Cicav-remote", "server/cicav/Cicav.py",
                  "server/cicav/constants.py", "server/cicav_conversions.py",
                  "server/cicav_proxy.py", "server/cicav/ttypes.py",
                  "server/discipline_proxy.py", "server/remote_discipline.py"]
      assert_equal expected.sort, filenames
    end
  end

  test "should generate server as zip content" do
    skip "Apache Thrift not installed" unless thrift?
    zippath = File.new("/tmp/test_mda_file.zip", "wb")
    File.open(zippath, "wb") do |f|
      content, _ = @sgen.generate with_server: true
      f.write content
    end
    assert File.exist?(zippath)
    Zip::File.open(zippath) do |zip|
      expected = ["run_server.py",
                  "server/__init__.py", "server/analysis.thrift", "server/cicav/__init__.py",
                  "server/cicav/Cicav-remote", "server/cicav/Cicav.py",
                  "server/cicav/constants.py", "server/cicav_conversions.py",
                  "server/cicav_proxy.py", "server/cicav/ttypes.py",
                  "server/discipline_proxy.py", "server/remote_discipline.py"]
      assert_equal expected.sort, zip.map { |entry| entry.name }.sort
    end
  end
end
