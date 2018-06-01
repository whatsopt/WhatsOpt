require 'test_helper'
require 'whats_opt/server_generator'
require 'tmpdir'
require 'pathname'

class ServerGeneratorTest < ActiveSupport::TestCase

  def setup
    @mda = analyses(:cicav)
    @sgen = WhatsOpt::ServerGenerator.new(@mda)
  end

  test "should generate server code for an analysis" do
    Dir.mktmpdir do |dir|
      filepath = @sgen._generate_code dir
      assert File.exists?(filepath)
    end
  end
  
  test "should use thrift command to generate thrift code" do
    Dir.mktmpdir do |dir|
      ok, log = @sgen._generate_with_thrift(dir)
      assert ok
    end
  end
  
  test "should maintain a list of generated filepaths" do
    Dir.mktmpdir do |dir|
      @sgen._generate_code dir
      rootdir = Pathname.new(dir)
      filenames = @sgen.genfiles.map{|f| Pathname.new(f).relative_path_from(rootdir).to_s}.sort
      expected = ['run_server.py', 
                  'server/__init__.py', 'server/analysis.thrift', 'server/cicav/__init__.py', 
                  'server/cicav/Cicav-remote', 'server/cicav/Cicav.py', 
                  'server/cicav/constants.py', 'server/cicav_conversions.py', 
                  'server/cicav_proxy.py', 'server/cicav/ttypes.py']
      assert_equal expected.sort, filenames
    end
  end 
  
  test "should generate server as zip content" do
    zippath = File.new('/tmp/test_mda_file.zip', 'w')
    File.open(zippath, 'w') do |f|
      content, _ = @sgen.generate
      f.write content
    end
    assert File.exists?(zippath)
    Zip::File.open(zippath) do |zip|
      expected = ['run_server.py', 
                  'server/__init__.py', 'server/analysis.thrift', 'server/cicav/__init__.py', 
                  'server/cicav/Cicav-remote', 'server/cicav/Cicav.py', 
                  'server/cicav/constants.py', 'server/cicav_conversions.py',  
                  'server/cicav_proxy.py', 'server/cicav/ttypes.py']      
      assert_equal expected.sort, zip.map{|entry| entry.name}.sort
    end
  end 
  
end