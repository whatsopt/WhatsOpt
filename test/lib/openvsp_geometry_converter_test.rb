require 'test_helper'
require 'whats_opt/openvsp_geometry_converter'
require 'tmpdir'

class OpenvspGeometryConverterTest < ActiveSupport::TestCase

  def setup
    @filename = "launcher.vsp3"
    @vspconv = WhatsOpt::OpenvspGeometryConverter.new(sample_file(@filename))
  end
  
  test "should generate vspscript" do
    Dir.mktmpdir do |dir|
      filepath = @vspconv.generate_vspscript dir
      assert File.exists?(filepath)
    end
  end
    
  test "should make an x3d file from a vsp3 file" do
    dst = @vspconv.convert
    assert File.exist?(dst.path)
  end
  
  test "should generate apologize html when bad file format" do
    vspconv = WhatsOpt::OpenvspGeometryConverter.new(sample_file("fake_openvsp.vsp3"))
    dst = vspconv.convert
    content = File.new(dst).read
    expected = WhatsOpt::OpenvspGeometryConverter::SORRY_MESSAGE_HTML
    assert_equal expected, content 
  end
  
end