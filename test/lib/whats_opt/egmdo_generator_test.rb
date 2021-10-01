require "test_helper"
require "whats_opt/egmdo_generator"
require "tmpdir"
require "pathname"

class EgmdoGeneratorTest < ActiveSupport::TestCase

  def setup
    @mda = analyses(:cicav)
    @eggen = WhatsOpt::EgmdoGenerator.new(@mda)
  end

  test "should generate EGMDO code for an analysis" do
    Dir.mktmpdir do |dir|
      filepath = @eggen._generate_code dir
      assert File.exist?(filepath)
    end
  end

  test "should maintain a list of generated filepaths" do
    Dir.mktmpdir do |dir|
      @eggen._generate_code dir
      rootdir = Pathname.new(dir)
      filenames = @eggen.genfiles.map { |f| Pathname.new(f).relative_path_from(rootdir).to_s }.sort
      expected = ["egmdo/__init__.py", "egmdo/algorithms.py", "egmdo/cicav_egmda.py", "egmdo/doe_factory.py", 
                  "egmdo/gp_factory.py", "egmdo/random_analysis.py", "run_egdoe.py", "run_egmda.py", "run_egmdo.py"]
      assert_equal expected.sort, filenames
    end
  end

  test "should generate EGMDO code as zip content" do
    zippath = File.new("/tmp/test_mda_file.zip", "wb")
    File.open(zippath, "wb") do |f|
      content, _ = @eggen.generate with_egmdo: true
      f.write content
    end
    assert File.exist?(zippath)
    Zip::File.open(zippath) do |zip|
      expected = ["egmdo/__init__.py", "egmdo/algorithms.py",  "egmdo/cicav_egmda.py", "egmdo/doe_factory.py", "egmdo/gp_factory.py", 
                  "egmdo/random_analysis.py", "run_egdoe.py", "run_egmda.py", "run_egmdo.py"]
      assert_equal expected.sort, zip.map { |entry| entry.name }.sort
    end
  end
end
