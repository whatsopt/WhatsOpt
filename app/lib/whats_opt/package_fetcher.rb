# frozen_string_literal: true

require "whats_opt/code_generator"
require "rubygems/package"
require "zlib"

module WhatsOpt
  class PackageFetcher < CodeGenerator
    def initialize(mda, src_mda)
      super(mda, pkg_format: true)
      @src_mda = src_mda
      @genfiles = []
    end

    def _generate_code(gendir, options = {})
      @genfiles = []
      Dir.mktmpdir("fetch_#{@src_mda.impl.py_modulename}_") do |dir|
        files = WhatsOpt::PackageExtractor.new(@src_mda).extract(dir, src_only: true)

        files.each do |src_file|
          # skip root analysis implementation
          next if /#{@src_mda.impl.py_filename}$/.match?(src_file)
          next if /#{@src_mda.impl.py_basefilename}$/.match?(src_file)

          outfile = src_file
          outfile = outfile.gsub("/#{@src_mda.impl.py_modulename}/", "/#{@impl.py_modulename}/")

          src_dir = Pathname.new(dir)
          abs_outfile = Pathname.new(outfile)
          rel_outfile = abs_outfile.relative_path_from(src_dir)

          outfile = File.join(gendir, rel_outfile)
          FileUtils.mkdir_p File.dirname(outfile)
          File.open(outfile, "w") do |out|
            out << File.open(src_file).read.gsub("from #{@src_mda.impl.py_modulename}", "from #{@impl.py_modulename}")
          end
          @genfiles << outfile
        end
      end
      @genfiles
    end
  end
end
