require 'test_helper'
require 'whats_opt/excel_mda_importer'

class ExcelMdaImporterTest < ActiveSupport::TestCase

  def setup
    @emi = WhatsOpt::ExcelMdaImporter.new(sample_file("excel_mda_simple_sample.xlsm"))  
  end

  test "should get excel line count" do
    assert_equal 8, @emi.line_count
  end
  
  test "should get mda attributes" do
    assert_equal({name: "PRF CICAV"}, @emi.get_mda_attributes)
  end
  
  test "should get disciplines attributes" do
    assert_equal([{name: "Geometry"}, {name: "Aerodynamics"}, {name: "Control"}], @emi.get_disciplines_attributes)
  end

  test "should get variables attributes" do
    expected = {WhatsOpt::ExcelMdaImporter::CONTROL_NAME =>[{:name=>"wing_span", :shape=>"1", :type=>"Float", :units=>"m", :desc=>"Envergure totale du véhicule", :io_mode=>"out"}, 
        {:name=>"control_surfaces_number", :shape=>"1", :type=>"Integer", :units=>"deg", :desc=>"Nombre de gouvernes", :io_mode=>"out"}, 
        {:name=>"handling_qualities_inputs_table", :shape=>"(10,)", :type=>"Float", :units=>"", :desc=>"Points de vol pour l'analyse des QdV", :io_mode=>"out"},
        {:name=>"eigen_values_table", :shape=>'(10,)', :type => 'Float', :units => 'deg', :io_mode=>"in", :desc => "Valeurs propres des modes avion"}], 
      "Geometry"=>[{:name=>"wing_span", :shape=>'1', :type => 'Float', :units=>"m", :io_mode=>"in", :desc => "Envergure totale du véhicule"}, 
        {:name=>"control_surfaces_number", :shape=>'1', :type => 'Integer', :units => 'deg', :io_mode=>"in", :desc => "Nombre de gouvernes"},
        {:name=>"cockpit_length", :shape=>'1', :type => 'Float', :units=>"m", :io_mode=>"out", :desc => "Longueur du cockpit"}, 
        {:name=>"control_surfaces_number", :shape=>'1', :type => 'Integer', :units => 'deg', :io_mode=>"out", :desc => "Nombre de gouvernes"}, 
        {:name=>"airfoil_extrados_p0_table", :shape=>'(10,)', :type => 'Float', :units => '', :io_mode=>"in", :desc => "Profil aérodynamique au plan 0, coordonnées de l'extrados (BA vers BF)"}, 
        {:name=>"eigen_values_table", :shape=>'(10,)', :type => 'Float', :units => 'deg', :io_mode=>"in", :desc => "Valeurs propres des modes avion"}],
      "Aerodynamics"=>[{:name=>"wing_reference_surface", :shape=>'1', :type => 'Float', :units=>"m2", :io_mode=>"out", :desc => "Surface de référence totale du véhicule"}, 
        {:name=>"wing_airfoils_number_of_point", :shape=>'1', :type => 'Integer', :units => '', :io_mode=>"out", :desc => "Nombre de points des tables de profil aérodynamique"}, 
        {:name=>"airfoil_extrados_p0_table", :shape=>'(10,)', :type => 'Float', :units => '', :io_mode=>"out", :desc => "Profil aérodynamique au plan 0, coordonnées de l'extrados (BA vers BF)"}, 
        {:name=>"cockpit_length", :shape=>'1', :type => 'Float', :units=>"m", :io_mode=>"in", :desc => "Longueur du cockpit"}, 
        {:name=>"control_surfaces_number", :shape=>'1', :type => 'Integer', :units => 'deg', :io_mode=>"in", :desc => "Nombre de gouvernes"},  
        {:name=>"handling_qualities_inputs_table", :shape=>'(10,)', :type => 'Float', :units => '', :io_mode=>"in", :desc => "Points de vol pour l'analyse des QdV"},
        {:name=>"eigen_values_table", :shape=>'(10,)', :type => 'Float', :units => 'deg', :io_mode=>"in", :desc => "Valeurs propres des modes avion"}],
      "Control"=>[{:name=>"wing_reference_surface", :shape=>'1', :type => 'Float', :units=>"m2", :io_mode=>"in", :desc => "Surface de référence totale du véhicule"}, 
        {:name=>"wing_airfoils_number_of_point", :shape=>'1', :type => 'Integer', :units => '', :io_mode=>"in", :desc => "Nombre de points des tables de profil aérodynamique"}, 
        {:name=>"airfoil_extrados_p0_table", :shape=>'(10,)', :type => 'Float', :units => '', :io_mode=>"in", :desc => "Profil aérodynamique au plan 0, coordonnées de l'extrados (BA vers BF)"}, 
        {:name=>"cockpit_length", :shape=>'1', :type => 'Float', :units =>"m", :io_mode=>"in", :desc => "Longueur du cockpit"}, 
        {:name=>"control_surfaces_number", :shape=>'1', :type => 'Integer', :units => 'deg', :io_mode=>"in", :desc => "Nombre de gouvernes"}, 
        {:name=>"handling_qualities_inputs_table", :shape=>'(10,)', :type => 'Float', :units => '', :io_mode=>"in", :desc => "Points de vol pour l'analyse des QdV"}, 
        {:name=>"handling_qualities_inputs_table" , :shape=>'(10,)', :type => 'Float', :units => '', :io_mode=>"out", :desc => "Points de vol pour l'analyse des QdV"}, 
        {:name=>"eigen_values_table", :shape=>'(10,)', :type => 'Float', :units => 'deg', :io_mode=>"out", :desc => "Valeurs propres des modes avion"}]}
    actual = @emi.get_variables_attributes
    assert_equal expected.size, actual.size, "Bad discipline count"
    expected.each do |k, vars| 
      assert actual.key?(k)
      assert_equal expected[k].size, actual[k].size, "Bad variable count for discipline #{k}"
      vars.each do |v|     
        assert_equal expected[k], actual[k], "Bad variables values for discipline #{k}"   
      end 
    end
  end
  
  
  
  test "should transform index in discipline name" do
    assert_equal WhatsOpt::ExcelMdaImporter::CONTROL_NAME, @emi._to_discipline('x')
    assert_equal "Geometry", @emi._to_discipline('0')
  end
    
  test "should import disciplines" do
    assert_equal ['Geometry', 'Aerodynamics', 'Control'],
      @emi._import_disciplines_data
  end

  test "should import variables" do
    assert_equal({'handling_qualities_inputs_table'=> {name: 'handling_qualities_inputs_table', shape: '(10,)', type: 'Float', units: '', 
                  desc: "Points de vol pour l'analyse des QdV" }, 
                  'control_surfaces_number'=> {name: 'control_surfaces_number', shape: '1', type: 'Integer', units: 'deg', 
                  desc: "Nombre de gouvernes"}, 
                  'eigen_values_table'=> {name: 'eigen_values_table', shape: '(10,)', type: 'Float', units: 'deg', 
                  desc: "Valeurs propres des modes avion"},
                  'wing_reference_surface'=> {name: 'wing_reference_surface', shape: '1', type: 'Float', units: 'm2', 
                  desc: "Surface de référence totale du véhicule"},
                  'wing_span'=> {name: 'wing_span', shape: '1', type: 'Float', units: 'm', 
                  desc: "Envergure totale du véhicule"},
                  'cockpit_length'=> {name: 'cockpit_length', shape: '1', type: 'Float', units: 'm', 
                  desc: "Longueur du cockpit"},
                  'wing_airfoils_number_of_point'=> {name: 'wing_airfoils_number_of_point', shape: '1', type: 'Integer', units: '', 
                  desc: "Nombre de points des tables de profil aérodynamique"},
                  'airfoil_extrados_p0_table'=> {name: 'airfoil_extrados_p0_table', shape: '(10,)', type: 'Float', units: '', 
                  desc: "Profil aérodynamique au plan 0, coordonnées de l'extrados (BA vers BF)"}
                  }, 
                  @emi._import_variables_data)
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
      'Y2x'=> ['eigen_values_table'],
      'Y2'=> ['eigen_values_table']
    }, @emi._import_connections_data)
  end

end

class ExcelMdaImporterErrorTest < ActiveSupport::TestCase

  test "should raise error when not an excel file" do
    assert_raises WhatsOpt::ExcelMdaImporter::ImportError do
      @emi = WhatsOpt::ExcelMdaImporter.new(sample_file("notebook_sample.ipynb"))  
    end 
  end
  
end
