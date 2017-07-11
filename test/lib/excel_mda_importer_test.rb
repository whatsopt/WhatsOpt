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
    expected = {"__User__"=>[{:name=>"eigen_values_table", :shape=>'10', :type => 'Float', :units => '', :io_mode=>"in"}], 
      "Geometry"=>[{:name=>"wing_span", :shape=>'1', :type => 'Float', :units=>"m", :io_mode=>"in"}, 
        {:name=>"control_surfaces_number", :shape=>'1', :type => 'Integer', :units => '', :io_mode=>"in"},
        {:name=>"cockpit_length", :shape=>'1', :type => 'Float', :units=>"m", :io_mode=>"out"}, 
        {:name=>"control_surfaces_number", :shape=>'1', :type => 'Integer', :units => '', :io_mode=>"out"}, 
        {:name=>"airfoil_extrados_p0_table", :shape=>'10', :type => 'Float', :units => '', :io_mode=>"in"}], 
      "Aerodynamics"=>[{:name=>"wing_reference_surface", :shape=>'1', :type => 'Float', :units=>"m2", :io_mode=>"out"}, 
        {:name=>"wing_airfoils_number_of_point", :shape=>'1', :type => 'Integer', :units => '', :io_mode=>"out"}, 
        {:name=>"airfoil_extrados_p0_table", :shape=>'10', :type => 'Float', :units => '', :io_mode=>"out"}, 
        {:name=>"cockpit_length", :shape=>'1', :type => 'Float', :units=>"m", :io_mode=>"in"}, 
        {:name=>"control_surfaces_number", :shape=>'1', :type => 'Integer', :units => '', :io_mode=>"in"},  
        {:name=>"handling_qualities_inputs_table", :shape=>'10', :type => 'Float', :units => '', :io_mode=>"in"}],
      "Control"=>[{:name=>"wing_reference_surface", :shape=>'1', :type => 'Float', :units=>"m2", :io_mode=>"in"}, 
        {:name=>"wing_airfoils_number_of_point", :shape=>'1', :type => 'Integer', :units => '', :io_mode=>"in"}, 
        {:name=>"airfoil_extrados_p0_table", :shape=>'10', :type => 'Float', :units => '', :io_mode=>"in"}, 
        {:name=>"cockpit_length", :shape=>'1', :type => 'Float', :units =>"m", :io_mode=>"in"}, 
        {:name=>"control_surfaces_number", :shape=>'1', :type => 'Integer', :units => '', :io_mode=>"in"}, 
        {:name=>"handling_qualities_inputs_table", :shape=>'10', :type => 'Float', :units => '', :io_mode=>"in"}, 
        {:name=>"handling_qualities_inputs_table" , :shape=>'10', :type => 'Float', :units => '', :io_mode=>"out"}, 
        {:name=>"eigen_values_table", :shape=>'10', :type => 'Float', :units => '', :io_mode=>"out"}]}
    actual = @emi.get_variables_attributes
    expected.each do |k, vars| 
      assert actual.key?(k)
      vars.each do |v| 
        found = false        
        actual[k].each do |a|
          flag = true
          [:name, :shape, :type, :units, :io_mode].each do |vk|
            flag &&= (a[vk] == v[vk])
          end
          if flag
            found = flag
            break
          end
        end
        assert found, "#{v} not found in #{actual[k]}"
      end 
    end
  end
  
  
  
  test "should transform index in discipline name" do
    assert_equal WhatsOpt::ExcelMdaImporter::USER_DISCIPLINE, @emi._to_discipline('x')
    assert_equal "Geometry", @emi._to_discipline('0')
  end
    
  test "should import disciplines" do
    assert_equal ['Geometry', 'Aerodynamics', 'Control'],
      @emi._import_disciplines_data
  end

  test "should import variables" do
    assert_equal({'handling_qualities_inputs_table'=> {name: 'handling_qualities_inputs_table', shape: '10', type: 'Float', units: '', 
                  desc: "Points de vol pour l'analyse des QdV" }, 
                  'control_surfaces_number'=> {name: 'control_surfaces_number', shape: '1', type: 'Integer', units: '', 
                  desc: "Nombre de gouvernes"}, 
                  'eigen_values_table'=> {name: 'eigen_values_table', shape: '10', type: 'Float', units: '', 
                  desc: "Valeurs propres des modes avion"},
                  'wing_reference_surface'=> {name: 'wing_reference_surface', shape: '1', type: 'Float', units: 'm2', 
                  desc: "Surface de référence totale du véhicule"},
                  'wing_span'=> {name: 'wing_span', shape: '1', type: 'Float', units: 'm', 
                  desc: "Envergure totale du véhicule"},
                  'cockpit_length'=> {name: 'cockpit_length', shape: '1', type: 'Float', units: 'm', 
                  desc: "Longueur du cockpit"},
                  'wing_airfoils_number_of_point'=> {name: 'wing_airfoils_number_of_point', shape: '1', type: 'Integer', units: '', 
                  desc: "Nombre de points des tables de profil aérodynamique"},
                  'airfoil_extrados_p0_table'=> {name: 'airfoil_extrados_p0_table', shape: '10', type: 'Float', units: '', 
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
      'Y2x'=> ['eigen_values_table']
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
