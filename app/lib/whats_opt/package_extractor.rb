# frozen_string_literal: true

module WhatsOpt
  class PackageExtractor

    attr_accessor :genfiles, :prefix

    def initialize(mda)
      @mda = mda
    end

    def extract(gendir)
      pkgfile = ActiveStorage::Blob.service.path_for(@mda.package.archive.key)

      excludes = File.join(File.dirname(__FILE__), 'excluded-files.txt')

      tar_cmd = "tar xvf #{pkgfile} --strip-components=1 --exclude-from=#{excludes} -C #{gendir}"
      Rails.logger.info tar_cmd
      `#{tar_cmd}`
    end

  end
end