# frozen_string_literal: true

require "thrift"
require "surrogate_store"

module WhatsOpt
  class SurrogateProxy < ServiceProxy
    def _initialize
      @surrogate_protocol = Thrift::MultiplexedProtocol.new(
        @protocol, "SurrogateStoreService"
      )
      @client = Services::SurrogateStore::Client.new(@surrogate_protocol)
    end

    def create_surrogate(surrogate_kind, x, y, options = {}, uncertainties = [])
      opts = {}
      options.each do |ks, v|
        k = ks.to_s
        opts[k] = Services::OptionValue.new(vector: JSON.parse(v)) if /^\[.*\]$/.match?(v)
        opts[k] = Services::OptionValue.new(integer: v.to_i) if v == v.to_i.to_s
        opts[k] = Services::OptionValue.new(number: v.to_f) if !opts[k] && v =~ /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/
        opts[k] = Services::OptionValue.new(str: v.to_s) unless opts[k]
      end
      uncs = uncertainties.filter_map { |us|
        u = us.transform_keys { |k| k.to_sym }
        Services::Distribution.new(name: u[:name], kwargs: u[:kwargs].to_h { |ks, v| [ks.to_s, v.to_f] }) unless u.blank?
      }
      _send { @client.create_surrogate(@id, surrogate_kind, x, y, opts, uncs) }
    end

    def qualify(xv, yv)
      quality = nil
      _send { quality = @client.qualify(@id, xv, yv) }
      quality
    end

    def predict_values(x)
      values = []
      _send {
        values = @client.predict_values(@id, x)
      }
      values
    end

    def destroy_surrogate
      _send { @client.destroy_surrogate(@id) }
    end

    def copy_surrogate(src_id)
      _send { @client.copy_surrogate(src_id, @id) }
    end

    def get_sobol_pce_sensitivity_analysis
      sobol_indices = nil
      _send { sobol_indices = @client.get_sobol_pce_sensitivity_analysis(@id) }
      sobol_indices
    end

    def _send
      @transport.open()
      yield
    rescue Services::SurrogateException => e
      # puts "#{e}: #{e.msg}"
      Rails.logger.warn "#{e}: #{e.msg}"
      raise
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
