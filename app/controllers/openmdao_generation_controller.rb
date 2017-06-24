require 'whats_opt/openmdao_generator'

class OpenmdaoGenerationController < ApplicationController

  def new
    if params[:mda_id]
      begin
        mda = MultiDisciplinaryAnalysis.find(params[:mda_id])
        ogen = WhatsOpt::OpenmdaoGenerator.new(mda)
        stringio, filename = ogen.generate_zip
        send_data stringio.read, filename: filename
      rescue ActiveRecord::RecordNotFound
        redirect_to multi_disciplinary_analyses_url, 
                    alert: "MDA(id=#{params[:mda_id]}) not found!"
      end
    else
      redirect_to multi_disciplinary_analyses_url,
                  alert: 'MDA not specified. Openmdao generation aborted!'
    end
  end  
  
end
