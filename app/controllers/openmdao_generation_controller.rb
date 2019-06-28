# frozen_string_literal: true

require "whats_opt/openmdao_generator"

class OpenmdaoGenerationController < ApplicationController
  def new
    mda_id = params[:mda_id]
    mda = Analysis.find(mda_id)
    authorize mda
    ogen = WhatsOpt::OpenmdaoGenerator.new(mda)
    stringio, filename = ogen.generate
    send_data stringio.read, filename: filename
  end
end
