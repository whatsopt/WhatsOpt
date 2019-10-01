# frozen_string_literal: true

require "whats_opt/openmdao_generator"

class Api::V1::OpenmdaoCheckingController < Api::ApiController
  # POST /api/v1/analysis/{mda_id}/openmdao_checking
  def create
    mda = Analysis.find(params[:mda_id])
    authorize mda
    ogen = WhatsOpt::OpenmdaoGenerator.new(mda, whatsopt_url: whatsopt_url, api_key: current_user.api_key, remote_ip: request.remote_ip)
    status, lines = ogen.check_mda_setup
    render json: { statusOk: status, log: lines }
  end
end
