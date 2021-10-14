# frozen_string_literal: true

require "whats_opt/cmdows_generator"
require "whats_opt/openmdao_generator"

class Api::V1::ComparisonsController < Api::ApiController
  def new
    mda_id = params[:mda_id]
    other_mda_id = params[:with]

    mda = Analysis.find(mda_id)
    other = Analysis.find(other_mda_id)

    authorize mda
    authorize other

    diff = WhatsOpt::AnalysisDiff.compare(other, mda) 

    render plain: diff
  end
end
