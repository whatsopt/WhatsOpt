require 'whats_opt/cmdows_generator'
require 'whats_opt/openmdao_generator'

class MdaExportsController < ApplicationController

  def new
    mda_id = params[:mda_id]
    format = params[:format]
    if mda_id
      begin
        mda = MultiDisciplinaryAnalysis.find(mda_id)
        if format == "openmdao"
          ogen = WhatsOpt::OpenmdaoGenerator.new(mda)
          stringio, filename = ogen.generate
          send_data stringio.read, filename: filename
        elsif format == "cmdows"
          cmdowsgen = WhatsOpt::CmdowsGenerator.new(mda)
          content, filename = cmdowsgen.generate
          send_data content, filename: filename, type:  'application/xml'
        else
          redirect_to mdas_url, alert: "Export format '#{format}' not handled!"
        end           
      rescue ActiveRecord::RecordNotFound
        redirect_to mdas_url, 
                    alert: "MDA(id=#{mda_id}) not found!"
      end
    else
      redirect_to mdas_url,
                  alert: 'MDA not specified. Export aborted!'
    end
  end  
  
end
