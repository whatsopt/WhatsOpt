# frozen_string_literal: true

class Api::V1::VersioningsController < Api::ApiController
  before_action :set_versions

  WOP_RECOMMENDED_VERSION = "~> 1.3.5"

  def show
    authorize :info
    json_response(@version)
  end

  private
    def set_versions
      @version = {}
      @version[:api] = "v1"
      @version[:whatsopt] = whatsopt_version
      @version[:wop] = WOP_RECOMMENDED_VERSION
    end

    def whatsopt_version
      filepath = File.join(Rails.root, "VERSION")
      File.read(filepath).chomp
    end

end
