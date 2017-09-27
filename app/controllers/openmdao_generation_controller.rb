require 'whats_opt/openmdao_generator'

class OpenmdaoGenerationController < ApplicationController

  def new
    mda_id = params[:mda_id]
    if mda_id
      begin
        mda = MultiDisciplinaryAnalysis.find(mda_id)
        ogen = WhatsOpt::OpenmdaoGenerator.new(mda)
        stringio, filename = ogen.generate_zip
        send_data stringio.read, filename: filename
      rescue ActiveRecord::RecordNotFound
        redirect_to mdas_url, 
                    alert: "MDA(id=#{mda_id}) not found!"
      end
    else
      redirect_to mdas_url,
                  alert: 'MDA not specified. Openmdao generation aborted!'
    end
  end  
  
end
