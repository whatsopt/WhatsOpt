# frozen_string_literal: trueTypes

require "thrift"
require "sensitivity_analyser"

module WhatsOpt
  class SensitivityAnalyserProxy < ServiceProxy
    def _initialize
      @analyser_protocol = Thrift::MultiplexedProtocol.new(
        @protocol, "SensitivityAnalyserService"
      )
      @client = Services::SensitivityAnalyser::Client.new(@analyser_protocol)
    end

    def compute_hsic(xdoe, ydoe, thresholding, quantile, g_threshold)
      hsic = nil
      _send { hsic = @client.compute_hsic(xdoe, ydoe, thresholding, quantile, g_threshold) }
      hsic
    end

    def _send
      @transport.open()
      yield
    rescue Thrift::TransportException => e
      # puts "#{e}"
      Rails.logger.warn e
      false
    else
      true
    ensure
      @transport.close()
    end
  end
end
