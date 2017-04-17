require 'test_helper'
require 'whats_opt/excel_mda_importer'

class ExcelMdaImporterTest < ActiveSupport::TestCase

  def setup
    @emi = WhatsOpt::ExcelMdaImporter.new(sample_file("excel_mda_simple_sample.xlsm"))  
  end

  test "should get excel line count" do
    assert_equal 8, @emi.line_count
  end
  
  test "should import disciplines" do
    assert_equal ['Geometry', 'Control'], @emi.get_disciplines
  end

  test "should import variables of given discipline" do
    assert_equal [{name: 'flight_qualities_point', type: 'table', unit: '(-)'}, 
                  {name: 'nb_rctrl_surface', type: 'scalaire', unit: '(-)'}, 
                  {name: 'ctrl_surface_chord', type: 'table', unit: 'm'}, 
                  {name: 'lambda_table', type: 'table', unit: '(-)'}], 
                  @emi.get_variables('Control')
  end
  
  test "should import connections" do
    skip('not yet implemented')
    assert_equal({
      Y02: ['nb_rctrl_surface', 'ctrl_surface_chord', 'ctrl_surface_root_pos_y', 'ctrl_surface_tip_pos_y', 'rudder_chord'], 
      Y03: ['nb_rctrl_surface', 'ctrl_surface_chord', 'ctrl_surface_root_pos_y', 'ctrl_surface_tip_pos_y', 'rudder_chord'], 
       X5: ['flight_qualities_point_table', 'ctrl_surface_role'], 
       X0: ['nb_rctrl_surface', 'ctrl_surface_chord', 'rudder_chord'],
      Y5x: ['lambda_table']
    }, @emi.get_connections('Control'))
  end
  
  test "should generate apologize html when bad file format" do
    skip("not yet implemented")
  end

end

