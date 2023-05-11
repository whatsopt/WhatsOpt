# frozen_string_literal: true

require "whats_opt/code_generator"
require 'rubygems/package'
require 'zlib'

module WhatsOpt
  class PackageFetcher < CodeGenerator

    def initialize(mda, src_mda)
      super(mda, pkg_format: true)
      @src_mda = src_mda
      @genfiles = []
    end

    def _generate_code(gendir, options = {})
      @genfiles = []
      Dir.mktmpdir("fetch_#{@src_mda.py_modulename}_") do |dir|
        files = WhatsOpt::PackageExtractor.new(@src_mda).extract(dir, src_only: true)

        files.each do |src_file|
          # skip root analysis implementation
          next if src_file =~ /#{@src_mda.py_filename}$/
          next if src_file =~ /#{@src_mda.py_basefilename}$/

          outfile = src_file
          outfile = outfile.gsub("/#{@src_mda.py_modulename}/", "/#{@mda.py_modulename}/")

          src_dir = Pathname.new(dir)
          abs_outfile = Pathname.new(outfile)
          rel_outfile = abs_outfile.relative_path_from(src_dir)

          outfile = File.join(gendir, rel_outfile)
          FileUtils.mkdir_p File.dirname(outfile)
          File.open(outfile, 'w') do |out|
            out << File.open(src_file).read.gsub("from #{@src_mda.py_modulename}", "from #{@mda.py_modulename}")
          end
          @genfiles << outfile
        end
      end
      @genfiles
    end

  end
end