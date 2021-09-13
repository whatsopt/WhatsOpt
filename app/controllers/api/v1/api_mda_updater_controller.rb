# frozen_string_literal: true

class Api::V1::ApiMdaUpdaterController < Api::ApiController
  def check_mda_update
    errmsg = "Analysis has been updated concurrently by another user. Please refresh and retry."
    raise Api::StaleObjectError.new(errmsg) if current_update_time > (request_time + 1.second)
  end
  
  def current_update_time
    raise "Cannot check mda update: Analysis not set" if @mda.nil?
    @mda.updated_at
  end

  def request_time
    raise "Cannot check mda update: Request time unknown. Set 'requested_at' parameter." if params[:requested_at].nil?
    DateTime.parse(params[:requested_at])
  end

  def touch_mda
    @mda.touch
  end

  def save_journal
    @mda.save_journal
  end
end