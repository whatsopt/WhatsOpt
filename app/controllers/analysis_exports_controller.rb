# frozen_string_literal: true

require "whats_opt/cmdows_generator"
require "whats_opt/openmdao_generator"
require "whats_opt/gemseo/generator"

class AnalysisExportsController < ApplicationController
  def new
    mda_id = params[:mda_id]
    format = params[:format]
    mda = Analysis.find(mda_id)
    authorize mda
    if format == "openmdao"
      ogen = WhatsOpt::OpenmdaoGenerator.new(mda)
      content, filename = ogen.generate
      send_data content, filename: filename
    elsif format == "openmdao"
      begin
        ggen = WhatsOpt::Gemseo::Generator.new(mda)
      rescue WhatsOpt::Gemseo::Generator::NotYetImplementedError => e
        redirect_to mdas_url, alert: "GEMSEO export failure: #{e}!"
      end
      content, filename = ggen.generate
      send_data content, filename: filename
    elsif format == "cmdows"
      cmdowsgen = WhatsOpt::CmdowsGenerator.new(mda)
      content, filename = cmdowsgen.generate
      begin
        cmdowsgen.valid?
      rescue WhatsOpt::CmdowsGenerator::CmdowsValidationError => e
        Rails.logger.warn "CMDOWS export warning: CMDOWS validation error"
        Rails.logger.warn "CMDOWS export warning: #{e}"
      end
      send_data content, filename: filename, type:  "application/xml"
    else
      redirect_to mdas_url, alert: "Export format '#{format}' not handled!"
    end
  end
end
