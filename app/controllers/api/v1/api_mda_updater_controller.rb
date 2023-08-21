# frozen_string_literal: true

class Api::V1::ApiMdaUpdaterController < Api::ApiController
  def check_mda_update
    errmsg = "Analysis has been updated concurrently by another user. Please refresh and retry."
    # Tolerance +5s: concurrent edit may be unnoticed but prevent from same user rapid updates being rejected
    # p "COMPARE >>>>>>>>> #{current_update_time} > #{request_time + 5.seconds} "
    raise Api::StaleObjectError.new(errmsg) if current_update_time > (request_time + 5.seconds)
  end

  def current_update_time
    raise "Cannot check mda update: Analysis not set" if @mda.nil?
    @mda.updated_at
  end

  def request_time
    raise "Cannot check mda update: Request time unknown. Set 'requested_at' parameter." if params[:requested_at].nil?
    Time.parse(params[:requested_at])
  end

  def touch_mda
    unless @disable_touch_mda_action
      @mda.touch
    end
  end

  def save_journal
    unless @disable_save_journal_action
      @mda.save_journal
    end
  end
end
