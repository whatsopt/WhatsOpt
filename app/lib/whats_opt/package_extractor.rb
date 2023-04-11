# frozen_string_literal: true

module WhatsOpt
  class PackageExtractor

    attr_accessor :genfiles, :prefix

    def initialize(mda)
      @mda = mda
      @genfiles = []
    end

    def extract(gendir)
      pkgfile = ActiveStorage::Blob.service.path_for(@mda.package.archive.key)

      excludes = File.join(File.dirname(__FILE__), 'excluded-files.txt')

      tar_cmd = "tar tf #{pkgfile} --strip-components=1 --exclude-from=#{excludes}"
      Rails.logger.info tar_cmd
      output = `#{tar_cmd}`
      @genfiles = output.split(/\n/)
      @genfiles = @genfiles.filter{|f| f[-1] != '/'}  # filter out directories
      @genfiles = @genfiles.map{|f| f[f.index('/')+1..]}  # strip root directory name
      @genfiles = @genfiles.map{|f| File.join(gendir, f)}  # prepend gendir

      tar_cmd = "tar xvf #{pkgfile} --strip-components=1 --exclude-from=#{excludes} -C #{gendir}"
      Rails.logger.info tar_cmd
      `#{tar_cmd}`

      @genfiles
    end

  end
end