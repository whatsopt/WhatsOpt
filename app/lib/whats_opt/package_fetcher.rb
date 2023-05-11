# frozen_string_literal: true

require "whats_opt/code_generator"
require 'rubygems/package'
require 'zlib'

module WhatsOpt
  class PackageFetcher < CodeGenerator

    def initialize(mda, src_mda)
      super(mda, pkg_format: true)
    end

    def _generate_code(gendir, options = {})
      @genfiles |= WhatsOpt::PackageExtractor.new(@mda).extract(gendir, src_only: true)
    end

  end
end