# frozen_string_literal: true

require "whats_opt/cmdows_generator"
require "whats_opt/openmdao_generator"

# Used by wop
class Api::V1::ExportsController < Api::ApiController
  def new
    mda_id = params[:mda_id]
    format = params[:format]
    with_server = (params[:with_server] == "true")
    with_egmdo = (params[:with_egmdo] == "true")
    with_runops = (params[:with_runops] == "true")
    with_unittests = (params[:with_unittests] == "true")
    with_run=true

    user_agent = request.headers["User-Agent"]
    mda = Analysis.find(mda_id)
    authorize mda
    if format == "openmdao"
      ogen = WhatsOpt::OpenmdaoGenerator.new(mda, whatsopt_url: whatsopt_url,
                                             api_key: current_user.api_key, remote_ip: request.remote_ip)
      content, filename = ogen.generate(user_agent: user_agent, with_run: with_run, with_server: with_server, 
                                        with_egmdo: with_egmdo, with_runops: with_runops, with_unittests: with_unittests)
      send_data content, filename: filename
    elsif format == "gemseo"
      ggen = WhatsOpt::GemseoGenerator.new(mda)
      begin
        content, filename = ggen.generate(user_agent: user_agent, with_run: with_run, with_server: with_server, 
                                          with_egmdo: with_egmdo, with_runops: with_runops, with_unittests: with_unittests)
        send_data content, filename: filename                          
      rescue WhatsOpt::GemseoGenerator::NotYetImplementedError => e
        json_response({ message: "GEMSEO export failure: #{e}" }, :bad_request)
      end
    else
      json_response({ message: "Export format #{format} not known" }, :bad_request)
    end
  end
end
