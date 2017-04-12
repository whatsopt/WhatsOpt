require 'test_helper'
require 'whats_opt/excel_mda_importer'

class ExcelMdaImporterTest < ActiveSupport::TestCase

  def setup
    @emi = WhatsOpt::ExcelMdaImporter.new(sample_file("excel_mda_sample.xlsm"))  
  end

  test "should read disciplines" do
    assert_equal ['Geometry', 'Propulsion', 'Aerodynamics', 'MCI', 'Mission',
                  'Structure', 'Control'], @emi.get_disciplines
  end

  test "should read variables" do
    assert_equal ['flight_qualities_point_table', 'nb_rctrl_surface', 
                  'ctrl_surface_chord', 'ctrl_surface_root_pos_y',
                  'ctrl_surface_tip_pos_y','ctrl_surface_role',
                  'rudder_chord','rudder_role','lambda_table'], 
                 @emi.get_variables('Control')
  end
  
  test "should generate apologize html when bad file format" do
    skip("not yet implemented")
  end

end

