require 'whats_opt/cmdows_generator'
require 'whats_opt/openmdao_generator'

class Api::V1::ExportsController < Api::ApiController

  def new
    mda_id = params[:mda_id]
    format = params[:format]
    user_agent = request.headers['User-Agent'] 
    mda = Analysis.find(mda_id)
    if format == "openmdao" || format == "openmdao_base"
      ogen = WhatsOpt::OpenmdaoGenerator.new(mda)
      content, filename = ogen.generate(only_base: (format == "openmdao_base"), user_agent: user_agent)
      send_data content, filename: filename
    elsif format == "cmdows"
      cmdowsgen = WhatsOpt::CmdowsGenerator.new(mda)
      content, filename = cmdowsgen.generate
      begin
        cmdowsgen.valid?
      rescue WhatsOpt::CmdowsGenerator::CmdowsValidationError => e
        Rails.logger.warn "CMDOWS export warning: CMDOWS validation error"
        Rails.logger.warn "CMDOWS export warning: #{e}"
      end
      send_data content, filename: filename, type:  'application/xml'
    else
      json_response({ message: "Export format #{format} not knwon" }, :bad_request)
    end           
  end  
  
end
