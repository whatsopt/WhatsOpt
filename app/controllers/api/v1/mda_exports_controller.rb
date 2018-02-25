require 'whats_opt/cmdows_generator'
require 'whats_opt/openmdao_generator'

class Api::V1::MdaExportsController < Api::ApiController

  def new
    mda_id = params[:mda_id]
    format = params[:format]
    mda = Analysis.find(mda_id)
    if format == "openmdao"
      ogen = WhatsOpt::OpenmdaoGenerator.new(mda)
      stringio, filename = ogen.generate
      send_data stringio.read, filename: filename
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
