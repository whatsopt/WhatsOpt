# frozen_string_literal: true

module WhatsOpt::Version
  VERSION = File.read(File.expand_path("VERSION", Rails.root)).chomp

  WOP_MINIMAL_VERSION = "1.15.4"

  class WopVersionMismatchException < Exception; end

  def self.included(base)
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

    def wop_recommended_version
      ">= #{WOP_MINIMAL_VERSION}"
    end

    def check_wop_minimal_version(wop_version)
      if Gem::Version.new(WOP_MINIMAL_VERSION) > Gem::Version.new(wop_version)
        raise WopVersionMismatchException.new(
          "Minimal wop version required #{WOP_MINIMAL_VERSION}, yours is #{wop_version}. " +
          "Please upgrade wop with 'pip install -U wop'.")
      end
    end
  end
end
