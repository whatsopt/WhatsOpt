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
    assert_equal([{name: WhatsOpt::Discipline::NULL_DRIVER_NAME}, 
                  {id: "14", name: "Disc1"}, {id: "15", name: "Disc2"}, {id: "16", name: "Disc3"}], 
                 @cmi.get_disciplines_attributes)
  end

  test "should get variables attributes" do
    expected = {WhatsOpt::Discipline::NULL_DRIVER_NAME => [],
      "14"=>[{:name=>"x1", :shape=>"1", :type=>"Float", :units=>"", :desc=>"", :io_mode=>"in"}, 
        {:name=>"z", :shape=>"1", :type=>"Float", :units=>"", :desc=>"", :io_mode=>"in"}, 
        {:name=>"y2", :shape=>"1", :type=>"Float", :units=>"", :desc=>"", :io_mode=>"in"}, 
        {:name=>"y", :shape=>"1", :type=>"Float", :units=>"", :desc=>"", :io_mode=>"out"}], 
      "15"=>[{:name=>"x2", :shape=>"1", :type=>"Float", :units=>"", :desc=>"", :io_mode=>"in"}, 
        {:name=>"z", :shape=>"1", :type=>"Float", :units=>"", :desc=>"", :io_mode=>"in"}, 
        {:name=>"y", :shape=>"1", :type=>"Float", :units=>"", :desc=>"", :io_mode=>"in"}, 
        {:name=> "y2", :shape=>"1", :type=>"Float", :units=>"", :desc=>"", :io_mode=>"out"}, 
        {:name=>"y", :shape=>"1", :type=>"Float", :units=>"", :desc=>"", :io_mode=>"out"}], 
      "16"=>[{:name=>"y", :shape=>"1", :type=>"Float", :units=>"", :desc=>"", :io_mode=>"in"}, 
        {:name=>"y2", :shape=>"1", :type=>"Float", :units=>"", :desc=>"", :io_mode=>"in"},
        {:name=>"z", :shape=>"1", :type=>"Float", :units=>"", :desc=>"", :io_mode=>"out"}]
    }
    assert_equal(expected, @cmi.get_variables_attributes)
  end
  
  test "should load AGILE cmdows as xml files" do
    @cmi2 = WhatsOpt::CmdowsMdaImporter.new(sample_file("cmdows_agile_fpg_mdf_gs.xml").path)  
  end
  
end

class CmdowsMdaImporterErrorTest < ActiveSupport::TestCase

  test "should raise error when cmdows file is invalid" do
    assert_raises WhatsOpt::CmdowsMdaImporter::CmdowsMdaImportError do
      @cmi = WhatsOpt::CmdowsMdaImporter.new(sample_file("cmdows_invalid.cmdows"))  
    end 
  end
  
end

class AgileCmdowsImportTest < ActiveSupport::TestCase

  test "should import cmdows coming from AGILE project" do
    @cmi = WhatsOpt::CmdowsMdaImporter.new(sample_file("cmdows_big_mda.cmdows"))
  end
  
end
