# frozen_string_literal: true

class Api::V1::JournalsController < Api::ApiController
  
  def show
    @mda = Analysis.find(params[:mda_id])
    authorize @mda
    json_response @mda.journals
  end

end