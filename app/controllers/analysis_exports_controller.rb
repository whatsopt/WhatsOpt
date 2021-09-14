# frozen_string_literal: true

require "whats_opt/cmdows_generator"
require "whats_opt/openmdao_generator"
require "whats_opt/gemseo/generator"

# Used by the browser
class AnalysisExportsController < ApplicationController
  def new
    mda_id = params[:mda_id]
    format = params[:format]
    with_server = (params[:with_server] == "true")
    with_runops = (params[:with_runops] == "true")
    with_unittests = (params[:with_unittests] == "true")
    with_run=true

    mda = Analysis.find(mda_id)
    authorize mda

    if format == "openmdao"
      ogen = WhatsOpt::OpenmdaoGenerator.new(mda, whatsopt_url: whatsopt_url,
                                             api_key: current_user.api_key, remote_ip: request.remote_ip)
      content, filename = ogen.generate(with_run: with_run,
                                        with_server: with_server, with_runops: with_runops, with_unittests: with_unittests)
      send_data content, filename: filename

    elsif format == "gemseo"
      ggen = WhatsOpt::Gemseo::Generator.new(mda, whatsopt_url: whatsopt_url,
                                             api_key: current_user.api_key, remote_ip: request.remote_ip)
      begin
        content, filename = ggen.generate(with_run: with_run,
                                          with_server: with_server, with_runops: with_runops, with_unittests: with_unittests)
        send_data content, filename: filename                          
      rescue WhatsOpt::Gemseo::Generator::NotYetImplementedError => e
        Rails.logger.warn "GEMSEO export error: #{e}"
        redirect_to mda_url(mda), alert: "GEMSEO export failed: #{e}"
      end

    elsif format == "cmdows"
      cmdowsgen = WhatsOpt::CmdowsGenerator.new(mda)
      content, filename = cmdowsgen.generate
      begin
        cmdowsgen.valid?
        send_data content, filename: filename, type:  "application/xml"
      rescue WhatsOpt::CmdowsGenerator::CmdowsValidationError => e
        Rails.logger.warn "CMDOWS export warning: CMDOWS validation error"
        Rails.logger.warn "CMDOWS export warning: #{e}"
        redirect_to mda_url(mda), alert: "CMDOWS export failed: #{e}"
      end

    elsif format == "html"
      htmlgen = WhatsOpt::HtmlGenerator.new(mda, url: self.request.base_url)
      content, filename = htmlgen.generate
      send_data content, filename: filename, type: "text/html"
    else
      redirect_to mdas_url, alert: "Export format '#{format}' not handled!"
    end
  end

private
  def whatsopt_url
    request.base_url + Rails.application.config.relative_url_root.to_s
  end
end
