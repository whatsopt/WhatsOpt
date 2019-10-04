# frozen_string_literal: true

require "test_helper"
require "whats_opt/openmdao_generator"
require "tmpdir"
require "mkmf" # for find_executable
MakeMakefile::Logging.instance_variable_set(:@log, File.open(File::NULL, "w"))

class OpenmdaoGeneratorTest < ActiveSupport::TestCase

  def thrift?
    @found ||= find_executable("thrift")
  end

  def setup
    @mda = analyses(:cicav)
    @ogen = WhatsOpt::OpenmdaoGenerator.new(@mda)
  end

  test "should generate openmdao component for a given discipline in mda" do
    skip "Apache Thrift not installed" unless thrift?
    Dir.mktmpdir do |dir|
      disc = @mda.disciplines[0]
      filepath = @ogen._generate_discipline disc, dir
      assert File.exist?(filepath)
      assert_match(/(\w+)_base\.py/, filepath)
    end
  end

  test "should generate openmdao process for an mda" do
    skip "Apache Thrift not installed" unless thrift?
    Dir.mktmpdir do |dir|
      @ogen._generate_code dir
      assert File.exist?(@ogen.genfiles.first)
    end
  end

  def _assert_file_generation(expected, with_server: true, with_runops: true, with_run: true, with_unittests: false)
    Dir.mktmpdir do |dir|
      @ogen._generate_code(dir, with_server: with_server, with_runops: with_runops, with_run: with_run, with_unittests: with_unittests)
      dirpath = Pathname.new(dir)
      basenames = @ogen.genfiles.map { |f| Pathname.new(f).relative_path_from(dirpath).to_s }.sort
      expected = (expected).sort
      assert_equal expected, basenames
    end
  end

  test "should maintain a list of generated filepaths without server" do
    expected = ["__init__.py", "aerodynamics.py", "aerodynamics_base.py", "cicav.py",
                "cicav_base.py", "geometry.py", "geometry_base.py", "propulsion.py", "propulsion_base.py",
                "run_analysis.py", "run_doe.py", "run_optimization.py",
                "run_screening.py"]
    _assert_file_generation expected, with_server: false
  end
  test "should maintain a list of generated filepaths without server and without optim" do
    obj = disciplines(:geometry).output_variables.where(name: 'obj')
    Connection.where(from: obj).update(role: WhatsOpt::Variable::RESPONSE_ROLE)
    expected = ["__init__.py", "aerodynamics.py", "aerodynamics_base.py", "cicav.py",
                "cicav_base.py", "geometry.py", "geometry_base.py", "propulsion.py", "propulsion_base.py",
                "run_analysis.py", "run_doe.py", "run_screening.py"]
    _assert_file_generation expected, with_server: false
  end

  test "should maintain a list of generated filepaths with unittests" do
    expected = ["__init__.py", "aerodynamics.py", "aerodynamics_base.py", "cicav.py",
                "cicav_base.py", "geometry.py", "geometry_base.py", "propulsion.py", "propulsion_base.py",
                "run_analysis.py", "run_doe.py", "run_optimization.py", "run_screening.py"] + ["test_aerodynamics.py", "test_geometry.py", "test_propulsion.py"]
    _assert_file_generation expected, with_server: false, with_unittests: true
  end

  test "should maintain a list of generated filepaths with optimization" do
    expected = ["__init__.py", "aerodynamics.py", "aerodynamics_base.py", "cicav.py",
                "cicav_base.py", "geometry.py", "geometry_base.py", "propulsion.py", "propulsion_base.py",
                "run_analysis.py", "run_doe.py", "run_optimization.py",
                "run_screening.py"] 
    _assert_file_generation expected, with_server: false
  end

  test "should maintain a list of generated filepaths with server" do
    skip "Apache Thrift not installed" unless thrift?
    expected = ["__init__.py", "aerodynamics.py", "aerodynamics_base.py", "cicav.py",
                "cicav_base.py", "geometry.py", "geometry_base.py", "propulsion.py", "propulsion_base.py",
                "run_analysis.py", "run_doe.py", "run_optimization.py",
                "run_screening.py"] + ["run_server.py",
                  "server/__init__.py", "server/analysis.thrift", "server/cicav/__init__.py",
                  "server/cicav/Cicav-remote", "server/cicav/Cicav.py",
                  "server/cicav/constants.py", "server/cicav_conversions.py",
                  "server/cicav_proxy.py", "server/cicav/ttypes.py",
                  "server/discipline_proxy.py", "server/remote_discipline.py", "server/sub_analysis_proxy.py"]
    _assert_file_generation expected
  end

  test "should generate openmdao mda zip file" do
    skip "Apache Thrift not installed" unless thrift?
    zippath = Tempfile.new("test_mda_file.zip")
    File.open(zippath, "w") do |f|
      content, _ = @ogen.generate
      f.write content
    end
    assert File.exist?(zippath)
    Zip::File.open(zippath) do |zip|
      zip.each do |entry|
        assert entry.file?
      end
    end
  end

  test "should generate openmdao mda zip base files" do
    skip "Apache Thrift not installed" unless thrift?
    zippath = Tempfile.new("test_mda_file.zip")
    File.open(zippath, "w") do |f|
      content, _ = @ogen.generate(only_base: true)
      f.write content
    end
    assert File.exist?(zippath)
    Zip::File.open(zippath) do |zip|
      zip.each do |entry|
        assert_match(/__init__.py|_base\.py|run_\w+\.py|server/, entry.name)
      end
    end
  end

  test "should run openmdao check and return true when valid" do
    skip "Apache Thrift not installed" unless thrift?
    ok, _log = @ogen.check_mda_setup
    assert ok  # ok even if discipline without connections
    # assert_empty log
  end

  test "should run openmdao check and return false when invalid" do
    skip "Apache Thrift not installed" unless thrift?
    mda = analyses(:fast)
    ogen2 = WhatsOpt::OpenmdaoGenerator.new(mda)
    ok, log = ogen2.check_mda_setup
    assert_not ok  # check raises a runtime error
    assert_match(/Error: Variable name .* already exists/, log.join(" "))
    # assert_match /already been used/, log.join(' ')  # thrift error
  end

  test "should run optimization as default" do
    skip_if_parallel
    skip "Apache Thrift not installed" unless thrift?
    Dir.mktmpdir do |dir|
      @ogen._generate_code dir
      pid = spawn("#{WhatsOpt::OpenmdaoGenerator::PYTHON} #{File.join(dir, 'run_server.py')}", [:out] => "/dev/null")
      @ogen_remote = WhatsOpt::OpenmdaoGenerator.new(@mda, server_host: "localhost")
      ok, log = @ogen_remote.run
      assert(ok, log)
      Process.kill("TERM", pid)
      Process.waitpid pid
    end
  end

  test "should run mda once" do
    skip_if_parallel
    skip "Apache Thrift not installed" unless thrift?
    Dir.mktmpdir do |dir|
      @ogen._generate_code dir
      pid = spawn("#{WhatsOpt::OpenmdaoGenerator::PYTHON} #{File.join(dir, 'run_server.py')}", [:out] => "/dev/null")
      @ogen_remote = WhatsOpt::OpenmdaoGenerator.new(@mda, server_host: "localhost", driver_name: "runonce")
      ok, log = @ogen_remote.run
      assert(ok, log)
      Process.kill("TERM", pid)
      Process.waitpid pid
    end
  end

  test "should run doe" do
    skip_if_parallel
    skip "Apache Thrift not installed" unless thrift?
    Dir.mktmpdir do |dir|
      @ogen._generate_code dir
      pid = spawn("#{WhatsOpt::OpenmdaoGenerator::PYTHON} #{File.join(dir, 'run_server.py')}", [:out] => "/dev/null")
      @ogen_remote = WhatsOpt::OpenmdaoGenerator.new(@mda, server_host: "localhost", driver_name: "smt_doe_lhs")
      ok, log = @ogen_remote.run :doe
      assert(ok, log)
      Process.kill("TERM", pid)
      Process.waitpid pid
    end
  end

  test "should run remote mda and return false when failed" do
    skip_if_parallel
    skip "Apache Thrift not installed" unless thrift?
    @ogen_remote = WhatsOpt::OpenmdaoGenerator.new(@mda, server_host: "localhost")
    ok, log = @ogen_remote.run
    assert_not ok
    assert_match(/Could not connect/, log.join(" "))
  end

  test "should monitor remote mda" do
    skip_if_parallel
    skip "Apache Thrift not installed" unless thrift? 
    @ogen_remote = WhatsOpt::OpenmdaoGenerator.new(@mda, server_host: "localhost")
    lines = []
    status = @ogen_remote.monitor do |stdin, stdouterr, wait_thr|
      stdin.close
      while line = stdouterr.gets('\n')
        lines << line.chomp
      end
      wait_thr.value
    end
    assert_not status.success?
    assert_match(/Could not connect/, lines.join(" "))
  end

  test "should use init value for independant variables" do
    skip "Apache Thrift not installed" unless thrift?
    zippath = Tempfile.new("test_mda_file.zip")
    File.open(zippath, "w") do |f|
      content, _ = @ogen.generate
      f.write content
    end
    assert File.exist?(zippath)
    Zip::File.open(zippath) do |zip|
      zip.each do |entry|
        if entry.name =~ /cicav_base\.py/
          assert entry.get_input_stream.read =~
            Regexp.new(Regexp.escape("indeps.add_output('x1', 3.14)"), Regexp::MULTILINE)
        end
      end
    end
  end

  test "should generate nested group for nested mda" do
    skip "Apache Thrift not installed" unless thrift?
    mda = analyses(:outermda)
    ogen = WhatsOpt::OpenmdaoGenerator.new(mda)
    Dir.mktmpdir do |dir|
      ogen._generate_code dir
      dirpath = Pathname.new(dir)
      basenames = ogen.genfiles.map { |f| Pathname.new(f).relative_path_from(dirpath).to_s }.sort
      expected = (["__init__.py", "disc.py", "disc_base.py", "inner/__init__.py", "inner/inner.py", "inner/inner_base.py", "inner/plain_discipline.py",
        "inner/plain_discipline_base.py", "outer.py", "outer_base.py", "run_analysis.py", "run_doe.py", "run_screening.py", "run_server.py", "server/__init__.py", "server/analysis.thrift", "server/discipline_proxy.py", "server/outer/Outer-remote",
        "server/outer/Outer.py", "server/outer/__init__.py", "server/outer/constants.py", "server/outer/ttypes.py",
        "server/outer_conversions.py", "server/outer_proxy.py", "vacant_discipline.py", "vacant_discipline_base.py",
        "server/remote_discipline.py", "server/sub_analysis_proxy.py"]).sort
      assert_equal expected, basenames
    end
  end

  test "should generate metamodel code" do
    skip "Apache Thrift not installed" unless thrift?
    mda = analyses(:cicav_metamodel_analysis)
    ogen = WhatsOpt::OpenmdaoGenerator.new(mda)
    Dir.mktmpdir do |dir|
      dir = '/tmp'
      ogen._generate_code dir
      dirpath = Pathname.new(dir)
      basenames = ogen.genfiles.map { |f| Pathname.new(f).relative_path_from(dirpath).to_s }.sort
      assert_includes basenames, "meta_model_disc.py"
    end
  end
end
