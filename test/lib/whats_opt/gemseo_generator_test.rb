# frozen_string_literal: true

require "test_helper"
require "whats_opt/gemseo_generator"
require "tmpdir"

class GemseoGeneratorTest < ActiveSupport::TestCase
  def setup
    @mda = analyses(:cicav)
    @ggen = WhatsOpt::GemseoGenerator.new(@mda)
  end

  test "should generate gemseo process for an mda" do
    Dir.mktmpdir do |dir|
      @ggen._generate_code dir,  with_server: false
      assert File.exist?(@ggen.genfiles.first)
    end
  end

  def _assert_file_generation(expected, with_server: true, with_runops: true, with_run: true, with_unittests: false)
    Dir.mktmpdir do |dir|
      @ggen._generate_code(dir, with_server: with_server, with_runops: with_runops, with_run: with_run, with_unittests: with_unittests)
      dirpath = Pathname.new(dir)
      basenames = @ggen.genfiles.map { |f| Pathname.new(f).relative_path_from(dirpath).to_s }.sort
      expected = (expected).sort
      assert_equal expected, basenames
    end
  end

  test "should maintain a list of generated filepaths without server" do
    expected = ["__init__.py", "aerodynamics.py", "aerodynamics_base.py", "cicav.py",
                "cicav_base.py", "geometry.py", "geometry_base.py", "mda_init.py", "propulsion.py", "propulsion_base.py",
                "run_analysis.py",  "run_doe.py", "run_mda.py", "run_mdo.py", "run_optimization.py", "run_parameters_init.py"]
    _assert_file_generation expected, with_server: false
  end

  test "should maintain a list of generated filepaths without server and without optim nor doe" do
    obj = disciplines(:geometry).output_variables.where(name: "obj")
    Connection.where(from: obj).update(role: WhatsOpt::Variable::RESPONSE_ROLE)
    expected = ["__init__.py", "aerodynamics.py", "aerodynamics_base.py", "cicav.py",
                "cicav_base.py", "geometry.py", "geometry_base.py", "mda_init.py", "propulsion.py", "propulsion_base.py",
                "run_analysis.py", "run_mda.py", 
                "run_parameters_init.py"]
    _assert_file_generation expected, with_server: false
  end

  test "should maintain a list of generated filepaths with optimization" do
    expected = ["__init__.py", "aerodynamics.py", "aerodynamics_base.py", "cicav.py",
                "cicav_base.py", "geometry.py", "geometry_base.py", "mda_init.py", "propulsion.py", "propulsion_base.py",
                "run_analysis.py", "run_mda.py", "run_mdo.py", "run_doe.py", "run_optimization.py", "run_parameters_init.py"]
    _assert_file_generation expected, with_server: false
  end

end
