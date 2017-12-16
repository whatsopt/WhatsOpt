require 'test_helper'
require 'whats_opt/cmdows_mda_importer'

class CmdowsMdaImporterTest < ActiveSupport::TestCase

  def setup
    @cmi = WhatsOpt::CmdowsMdaImporter.new(sample_file("cmdows_mda_sample.cmdows").path)  
  end

  test "should get mda attributes" do
    assert_equal({name: "CmdowsMdaSample"}, @cmi.get_mda_attributes)
  end
  
  test "should get disciplines attributes" do
  end

  test "should get variables attributes" do
  end
  
end

class CmdowsMdaImporterErrorTest < ActiveSupport::TestCase

  test "should raise error when not a cmdows file" do
    #assert_raises WhatsOpt::CmdowsMdaImporter::ImportError do
      #@cmi = WhatsOpt::CmdowsMdaImporter.new(sample_file(""))  
    #end 
  end
  
end
