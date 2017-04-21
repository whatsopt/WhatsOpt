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
    assert_equal ['Geometry', 'Aerodynamics', 'Control'], @emi.get_disciplines
  end

  test "should import variables of given discipline" do
    assert_equal [{name: 'handling_qualities_inputs_table', type: 'table', unit: '(-)'}, 
                  {name: 'control_surfaces_number', type: 'scalaire', unit: '(-)'}, 
                  {name: 'eigen_values_table', type: 'table', unit: '(-)'}], 
                  @emi.get_variables('Control')
  end
  
  test "should import connections" do
    assert_equal({
      'X0' => ['wing_span', 'control_surfaces_number'],
      'X2' => ['handling_qualities_inputs_table'],
      'Y01'=> ['cockpit_length', 'control_surfaces_number'],
      'Y02'=> ['cockpit_length', 'control_surfaces_number'],
      'Y10'=> ['airfoil_extrados_p0_table'],
      'Y12'=> ['wing_reference_surface', 'wing_airfoils_number_of_point', 'airfoil_extrados_p0_table'],
      'Y21'=> ['handling_qualities_inputs_table'], 
      'Y2x'=> ['eigen_values_table']
    }, @emi.get_connections)
  end
  
  test "should generate apologize html when bad file format" do
    skip("not yet implemented")
  end

end

