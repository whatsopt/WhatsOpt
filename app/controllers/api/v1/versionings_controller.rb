# frozen_string_literal: true

class Api::V1::VersioningsController < Api::ApiController
  include WhatsOpt::Version
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
      @version[:wop] = wop_recommended_version
    end
end
