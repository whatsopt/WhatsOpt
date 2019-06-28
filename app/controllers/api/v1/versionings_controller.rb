# frozen_string_literal: true

class Api::V1::VersioningsController < Api::ApiController
  before_action :set_versions

  def show
    authorize :info
    json_response(@version)
  end

  private
    def set_versions
      @version = {}
      @version[:api] = "v1"
      @version[:whatsopt] = whatsopt_version
      @version[:wop] = wop_version
    end

    def whatsopt_version
      filepath = File.join(Rails.root, "VERSION")
      File.read(filepath).chomp
    end

    def wop_version
      filepath = File.join(Rails.root, "wop", "whatsopt", "__init__.py")
      File.open(filepath).each do |line|
        line.chomp!
        if line =~ /^__version__='(.*)'$/
          return $1
        end
      end
      nil
    end
end
