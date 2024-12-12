# frozen_string_literal: true

require "test_helper"
require "whats_opt/openmdao_generator"
require "tmpdir"
require "mkmf" # for find_executable
MakeMakefile::Logging.instance_variable_set(:@log, File.open(File::NULL, "wb"))

class OpenmdaoGeneratorTest < ActiveSupport::TestCase
  @@server_port = 31400

  def thrift?
    @found ||= find_executable("thrift")
  end

  def setup
    @mda = analyses(:cicav)
    @ogen = WhatsOpt::OpenmdaoGenerator.new(@mda)
    @server_host = "localhost"
    @pid = -1
  end

  def start_server(ogen, dir)
    skip_if_parallel
    @@server_port += 1  # ensure we start on a different port for Github CI to avoid "Already in use" error
    # p "Start on #{@@server_port}"
    ogen.server_port = @@server_port
    ogen._generate_code dir
    cmd = "#{WhatsOpt::OpenmdaoGenerator::PYTHON} #{File.join(dir, 'run_server.py')} --port #{@@server_port}"
    # p cmd
    @pid = spawn(cmd, [:out] => "/dev/null")
    sleep(1) # wait 1s for server start
    # p "Process #{@pid} started"
    @pid
  end

  def stop_server()
    if @pid > 0
      Process.kill("TERM", @pid)
      Process.waitpid @pid;
      # p "Process #{@pid} stopped"
    end
  end


  test "should generate openmdao component for a given discipline in mda" do
    skip "Apache Thrift not installed" unless thrift?
    Dir.mktmpdir do |dir|
      disc = @mda.disciplines.nodes.first
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

  test "should generate openmdao process for a singleton mda" do
    @mda = analyses(:singleton)
    # XXX: Fixture does not seem to always load the file properly
    #      this ensure the presence of the file and avoid tar extraction error
    @mda.package.archive.attach(io: File.open(file_fixture("singleton-0.1.0.tar.gz")), filename: "singleton-0.1.0.tar.gz")
    assert File.exist?(ActiveStorage::Blob.service.path_for(@mda.package.archive.key))

    @ogen = WhatsOpt::OpenmdaoGenerator.new(@mda, pkg_format: true)
    Dir.mktmpdir do |dir|
      @ogen._generate_code(dir, with_server: false)
      assert File.exist?(@ogen.genfiles.first)
    end
  end

  def _assert_file_generation(expected, with_server: false, with_egmdo: false, with_runops: true, with_run: true, with_unittests: false)
    Dir.mktmpdir do |dir|
      @ogen._generate_code(dir, with_server: with_server, with_egmdo: with_egmdo, with_runops: with_runops, with_run: with_run, with_unittests: with_unittests)
      dirpath = Pathname.new(dir)
      basenames = @ogen.genfiles.map { |f| Pathname.new(f).relative_path_from(dirpath).to_s }.sort
      expected = (expected).sort
      assert_equal expected, basenames
    end
  end

  test "should maintain a list of generated filepaths without server" do
    expected = ["__init__.py", "aerodynamics.py", "aerodynamics_base.py", "cicav.py",
                "cicav_base.py", "geometry.py", "geometry_base.py", "mda_init.py",
                "propulsion.py", "propulsion_base.py",
                "run_mda.py", "run_mdo.py", "run_doe.py", "run_screening.py"]
    _assert_file_generation expected
  end

  test "should maintain a list of generated filepaths with egmdo" do
    expected = ["__init__.py", "aerodynamics.py", "aerodynamics_base.py", "cicav.py",
                "cicav_base.py", "geometry.py", "geometry_base.py", "mda_init.py",
                "propulsion.py", "propulsion_base.py", "run_mda.py", "run_mdo.py", "run_doe.py", "run_egdoe.py"] + [
                "egmdo/__init__.py", "egmdo/algorithms.py", "egmdo/cicav_egmda.py", "egmdo/doe_factory.py",
                "egmdo/gp_factory.py", "egmdo/random_analysis.py", "egmdo/random_vec_analysis.py",
                "run_egmda.py", "run_egmdo.py", "run_screening.py"
                ]
    _assert_file_generation expected, with_egmdo: true
  end

  test "should maintain a list of generated filepaths without server and without optim" do
    obj = disciplines(:geometry).output_variables.where(name: "obj")
    Connection.where(from: obj).update(role: WhatsOpt::Variable::RESPONSE_ROLE)
    expected = ["__init__.py", "aerodynamics.py", "aerodynamics_base.py", "cicav.py",
                "cicav_base.py", "geometry.py", "geometry_base.py", "mda_init.py",
                "propulsion.py", "propulsion_base.py",
                "run_mda.py", "run_mdo.py", "run_doe.py", "run_screening.py"]
    _assert_file_generation expected
  end

  test "should maintain a list of generated filepaths with unittests" do
    expected = ["__init__.py", "aerodynamics.py", "aerodynamics_base.py", "cicav.py",
                "cicav_base.py", "geometry.py", "geometry_base.py", "mda_init.py",
                "propulsion.py", "propulsion_base.py",
                "run_mda.py", "run_mdo.py", "run_doe.py", "run_screening.py"] +
                ["tests/test_aerodynamics.py", "tests/test_geometry.py", "tests/test_propulsion.py"]
    _assert_file_generation expected, with_unittests: true
  end

  test "should maintain a list of generated filepaths with optimization" do
    expected = ["__init__.py", "aerodynamics.py", "aerodynamics_base.py", "cicav.py",
                "cicav_base.py", "geometry.py", "geometry_base.py", "mda_init.py",
                "propulsion.py", "propulsion_base.py",
                "run_mda.py", "run_mdo.py", "run_doe.py", "run_screening.py"]
    _assert_file_generation expected
  end

  test "should maintain a list of generated filepaths with server" do
    skip "Apache Thrift not installed" unless thrift?
    expected = ["__init__.py", "aerodynamics.py", "aerodynamics_base.py", "cicav.py",
                "cicav_base.py", "geometry.py", "geometry_base.py", "mda_init.py", "propulsion.py", "propulsion_base.py",
                "run_mda.py", "run_mdo.py", "run_doe.py", "run_screening.py"] +
                ["run_server.py", "server/__init__.py", "server/analysis.thrift", "server/cicav/__init__.py",
                "server/cicav/Cicav-remote", "server/cicav/Cicav.py",
                "server/cicav/constants.py", "server/cicav_conversions.py",
                "server/cicav_proxy.py", "server/cicav/ttypes.py",
                "server/discipline_proxy.py", "server/remote_discipline.py"]
    _assert_file_generation expected, with_server: true
  end

  test "should maintain a list of generated filepaths in package mode" do
    skip "Apache Thrift not installed" unless thrift?
    # Remove attached package to test pristine package mode
    @mda.package = nil
    assert_not @mda.packaged?

    pkg_expected = ["__init__.py", "aerodynamics.py", "aerodynamics_base.py", "cicav.py",
                "cicav_base.py", "geometry.py", "geometry_base.py", "propulsion.py", "propulsion_base.py"] +
                ["egmdo/__init__.py", "egmdo/algorithms.py", "egmdo/cicav_egmda.py", "egmdo/doe_factory.py",
                "egmdo/gp_factory.py", "egmdo/random_analysis.py", "egmdo/random_vec_analysis.py"] +
                ["tests/test_aerodynamics.py", "tests/test_geometry.py", "tests/test_propulsion.py"] +
                ["server/__init__.py", "server/analysis.thrift", "server/cicav/__init__.py",
                "server/cicav/Cicav-remote", "server/cicav/Cicav.py",
                "server/cicav/constants.py", "server/cicav_conversions.py",
                "server/cicav_proxy.py", "server/cicav/ttypes.py",
                "server/discipline_proxy.py", "server/remote_discipline.py"]
    pkg_name = @mda.impl.py_modulename
    pkg_expected = pkg_expected.map { |f| "#{pkg_name}/#{f}" }
    expected = pkg_expected + ["mda_init.py", "run_mda.py", "run_mdo.py",
      "run_doe.py", "run_screening.py", "run_server.py",
      "run_egdoe.py", "run_egmda.py", "run_egmdo.py"] +
      [".gitignore", "README.md", "pyproject.toml"]
    @ogen_pkg = WhatsOpt::OpenmdaoGenerator.new(@mda, pkg_format: true)
    Dir.mktmpdir do |dir|
      @ogen_pkg._generate_code(dir, with_server: true, with_egmdo: true, with_runops: true, with_run: true, with_unittests: true)
      dirpath = Pathname.new(dir)
      basenames = @ogen_pkg.genfiles.map { |f| Pathname.new(f).relative_path_from(dirpath).to_s }.sort
      expected = (expected).sort
      assert_equal expected, basenames
    end
  end

  test "should maintain a list of generated filepaths in package mode with package attached" do
    skip "Apache Thrift not installed" unless thrift?
    assert @mda.packaged?

    # XXX: Fixture does not seem to always load the file properly
    #      this ensure the presence of the file
    @mda.package.archive.attach(io: File.open(file_fixture("cicav-0.1.0.tar.gz")), filename: "cicav-0.1.0.tar.gz")
    assert File.exist?(ActiveStorage::Blob.service.path_for(@mda.package.archive.key))

    pkg_expected = ["__init__.py", "aerodynamics.py", "aerodynamics_base.py", "cicav.py",
                "cicav_base.py", "geometry.py", "geometry_base.py", "propulsion.py", "propulsion_base.py"] +
                ["egmdo/__init__.py", "egmdo/algorithms.py", "egmdo/cicav_egmda.py", "egmdo/doe_factory.py",
                "egmdo/gp_factory.py", "egmdo/random_analysis.py", "egmdo/random_vec_analysis.py"] +
                ["tests/test_aerodynamics.py", "tests/test_geometry.py", "tests/test_propulsion.py"] +
                ["server/__init__.py", "server/analysis.thrift", "server/cicav/__init__.py",
                "server/cicav/Cicav-remote", "server/cicav/Cicav.py",
                "server/cicav/constants.py", "server/cicav_conversions.py",
                "server/cicav_proxy.py", "server/cicav/ttypes.py",
                "server/discipline_proxy.py", "server/remote_discipline.py"]
    pkg_name = @mda.impl.py_modulename
    pkg_expected = pkg_expected.map { |f| "#{pkg_name}/#{f}" }
    expected = pkg_expected + ["mda_init.py", "run_mda.py", "run_mdo.py",
      "run_doe.py", "run_screening.py", "run_server.py",
      "run_egdoe.py", "run_egmda.py", "run_egmdo.py"] +
      ["README.md", "pyproject.toml"]

    @ogen_pkg = WhatsOpt::OpenmdaoGenerator.new(@mda, pkg_format: true)
    Dir.mktmpdir do |dir|
      @ogen_pkg._generate_code(dir, with_server: true, with_egmdo: true, with_runops: true, with_run: true, with_unittests: true)
      dirpath = Pathname.new(dir)
      basenames = @ogen_pkg.genfiles.map { |f| Pathname.new(f).relative_path_from(dirpath).to_s }.sort
      expected = (expected).sort
      assert_equal expected, basenames
    end
  end

  test "should generate openmdao mda zip file" do
    skip "Apache Thrift not installed" unless thrift?
    zippath = Tempfile.new("test_mda_file.zip")
    File.open(zippath, "wb") do |f|
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

  test "should run openmdao check and return true when valid" do
    skip "Apache Thrift not installed" unless thrift?
    ok, _log = @ogen.check_mda_setup
    assert ok  # ok even if discipline without connections
    # assert_empty log
  end

  test "should run openmdao check and return true when using units" do
    skip "Apache Thrift not installed" unless thrift?
    @mda.openmdao_impl.update(use_units: true)
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
    assert_match(/Variable name .* already exists/, log.join(" "))
    # assert_match /already been used/, log.join(' ')  # thrift error
  end

  test "should run analysis as default" do
    skip_if_parallel
    skip "Apache Thrift not installed" unless thrift?
    Dir.mktmpdir do |dir|
      dir = "tmp/BUG"
      pid = self.start_server(@ogen, dir)
      @ogen_remote = WhatsOpt::OpenmdaoGenerator.new(@mda, server_host: "localhost", server_port: @@server_port)
      ok, log = @ogen_remote.run
      assert ok
      assert log
      self.stop_server
    end
  end

  test "should run mda once" do
    skip_if_parallel
    skip "Apache Thrift not installed" unless thrift?
    Dir.mktmpdir do |dir|
      pid = self.start_server(@ogen, dir)
      @ogen_remote = WhatsOpt::OpenmdaoGenerator.new(@mda, server_host: "localhost", server_port: @@server_port, driver_name: "runonce")
      ok, log = @ogen_remote.run
      assert ok
      assert log
      self.stop_server
    end
  end

  test "should run doe" do
    skip_if_parallel
    skip "Apache Thrift not installed" unless thrift?
    Dir.mktmpdir do |dir|
      # dir = "/tmp/SERVER_DOE"
      pid = self.start_server(@ogen, dir)
      @ogen_remote = WhatsOpt::OpenmdaoGenerator.new(@mda, server_host: "localhost", server_port: @@server_port, driver_name: "smt_doe_lhs")
      File.delete("cicav_doe.sqlite") if File.exist?("cicav_doe.sqlite")
      ok, log = @ogen_remote.run :doe
      assert ok
      assert log
      outdir = "./run_doe_out"  # since openmdao 3.35
      outfile = "#{outdir}/cicav_doe.sqlite"
      assert File.exist?(outfile)
      File.delete(outfile) if File.exist?(outfile)
      self.stop_server
    end
  end

  test "should run UQ doe" do
    skip_if_parallel
    skip "Apache Thrift not installed" unless thrift?
    @mda = analyses(:singleton_uq)
    Dir.mktmpdir do |dir|
      pid = self.start_server(@ogen, dir)
      @ogen_remote = WhatsOpt::OpenmdaoGenerator.new(@mda, server_host: "localhost", server_port: @@server_port)
      File.delete("singleton_uq_doe.sqlite") if File.exist?("singleton_uq_doe.sqlite")
      ok, log = @ogen_remote.run :doe
      assert ok
      assert log
      outdir = "./run_doe_out"  # since openmdao 3.35
      outfile = "#{outdir}/singleton_uq_doe.sqlite"
      assert File.exist?(outfile)
      File.delete(outfile) if File.exist?(outfile)
      self.stop_server
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

  test "should generate nested group for nested mda" do
    skip "Apache Thrift not installed" unless thrift?
    mda = analyses(:outermda)
    ogen = WhatsOpt::OpenmdaoGenerator.new(mda)
    Dir.mktmpdir do |dir|
      ogen._generate_code dir
      dirpath = Pathname.new(dir)
      basenames = ogen.genfiles.map { |f| Pathname.new(f).relative_path_from(dirpath).to_s }.sort
      expected = (["__init__.py", "disc.py", "disc_base.py", "inner/__init__.py", "inner/inner.py",
        "inner/inner_base.py", "inner/plain_discipline.py",
        "inner/plain_discipline_base.py", "mda_init.py", "outerpkg.py", "outerpkg_base.py", "run_mda.py",
        "run_mdo.py", "run_doe.py", "run_screening.py", "run_server.py", "server/__init__.py",
        "server/analysis.thrift", "server/discipline_proxy.py", "server/outerpkg/Outerpkg-remote",
        "server/outerpkg/Outerpkg.py", "server/outerpkg/__init__.py", "server/outerpkg/constants.py", "server/outerpkg/ttypes.py",
        "server/outerpkg_conversions.py", "server/outerpkg_proxy.py", "vacant_discipline.py", "vacant_discipline_base.py",
        "server/remote_discipline.py"]).sort
      assert_equal expected, basenames
    end
  end

  test "should generate packaged nested group for nested mda" do
    skip "Apache Thrift not installed" unless thrift?
    mda = analyses(:outermda)
    ogen = WhatsOpt::OpenmdaoGenerator.new(mda, pkg_format: true)
    Dir.mktmpdir do |dir|
      ogen._generate_code dir
      dirpath = Pathname.new(dir)
      basenames = ogen.genfiles.map { |f| Pathname.new(f).relative_path_from(dirpath).to_s }.sort
      expected = (["outerpkg/__init__.py", "outerpkg/disc.py", "outerpkg/disc_base.py", "outerpkg/inner/__init__.py", "outerpkg/inner/inner.py",
        "outerpkg/inner/inner_base.py", "outerpkg/inner/plain_discipline.py",
        "outerpkg/inner/plain_discipline_base.py", "mda_init.py", "outerpkg/outerpkg.py", "outerpkg/outerpkg_base.py", "run_mda.py",
        "run_mdo.py", "run_doe.py", "run_screening.py", "run_server.py", "outerpkg/server/__init__.py",
        "outerpkg/server/analysis.thrift", "outerpkg/server/discipline_proxy.py", "outerpkg/server/outerpkg/Outerpkg-remote",
        "outerpkg/server/outerpkg/Outerpkg.py", "outerpkg/server/outerpkg/__init__.py", "outerpkg/server/outerpkg/constants.py", "outerpkg/server/outerpkg/ttypes.py",
        "outerpkg/server/outerpkg_conversions.py", "outerpkg/server/outerpkg_proxy.py", "outerpkg/vacant_discipline.py", "outerpkg/vacant_discipline_base.py",
        "outerpkg/server/remote_discipline.py"] +
        [".gitignore", "README.md", "pyproject.toml"]).sort
      assert_equal expected, basenames
    end
  end

  test "should run nested mda once" do
    skip_if_parallel
    skip "Apache Thrift not installed" unless thrift?
    mda = analyses(:outermda)
    ogen = WhatsOpt::OpenmdaoGenerator.new(mda)
    Dir.mktmpdir do |dir|
      pid = self.start_server(ogen, dir)
      @ogen_remote = WhatsOpt::OpenmdaoGenerator.new(mda, server_host: "localhost", server_port: @@server_port, driver_name: "runonce")
      ok, log = @ogen_remote.run
      assert ok
      assert log
      self.stop_server
    end
  end

  test "should run packaged nested mda once" do
    skip_if_parallel
    skip "Apache Thrift not installed" unless thrift?
    mda = analyses(:outermda)
    ogen = WhatsOpt::OpenmdaoGenerator.new(mda, pkg_format: true)
    Dir.mktmpdir do |dir|
      pid = self.start_server(ogen, dir)
      @ogen_remote = WhatsOpt::OpenmdaoGenerator.new(mda, pkg_format: true, server_host: "localhost", server_port: @@server_port, driver_name: "runonce")
      ok, log = @ogen_remote.run
      assert ok
      assert log
      self.stop_server
    end
  end

  test "should generate metamodel code" do
    skip "Apache Thrift not installed" unless thrift?
    mda = analyses(:cicav_metamodel_analysis)
    ogen = WhatsOpt::OpenmdaoGenerator.new(mda)
    Dir.mktmpdir do |dir|
      dir = "/tmp"
      ogen._generate_code dir
      dirpath = Pathname.new(dir)
      basenames = ogen.genfiles.map { |f| Pathname.new(f).relative_path_from(dirpath).to_s }.sort
      assert_includes basenames, "meta_model_disc.py"
    end
  end
end
