module WhatsOpt::Version

  VERSION = File.read(File.expand_path("VERSION", Rails.root)).chomp

  def self.included base 
    base.send :include, InstanceMethods
  end

  module InstanceMethods

    def whatsopt_version_major
      whatsopt_version =~ /(\d+)\.(\d+)\.(\d+)/
      $1
    end
    def whatsopt_version_minor
      whatsopt_version =~ /(\d+)\.(\d+)\.(\d+)/
      $2
    end
    def whatsopt_version_patch
      whatsopt_version =~ /(\d+)\.(\d+)\.(\d+)/
      $3
    end
    def whatsopt_version_release
      whatsopt_version =~ /(\d+)\.(\d+)\.(\d+)\-(\d+)/
      $4
    end

    def whatsopt_version
      VERSION
    end

  end

end