require 'whats_opt/openmdao_generator'

class Api::V1::OpenmdaoCheckingController < Api::ApiController 

  # POST /api/v1/analysis/{mda_id}/openmdao_checking
  def create
    if params[:mda_id]
      mda = Analysis.find(params[:mda_id])
      if mda
        ogen = WhatsOpt::OpenmdaoGenerator.new(mda)
        status, lines = ogen.check_mda_setup 
        render json: {statusOk: status, log: lines}
      else
        render json: {error: true} 
      end 
    else
      render json: {error: true} 
    end 
  end
  
end
