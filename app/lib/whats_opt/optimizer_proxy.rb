# frozen_string_literal: true

require "thrift"
require "optimizer_store"

module WhatsOpt
  class OptimizerProxy < ServiceProxy
    CSTRS_TYPES = {
      "<" => WhatsOpt::Services::ConstraintType::LESS,
      "=" => WhatsOpt::Services::ConstraintType::EQUAL,
      ">" => WhatsOpt::Services::ConstraintType::GREATER,
    }

    def _initialize
      @protocol = Thrift::MultiplexedProtocol.new(
        @protocol, "OptimizerStoreService"
      )
      @client = Services::OptimizerStore::Client.new(@protocol)
    end

    def create_optimizer(optimizer_kind, xlimits, cstr_specs = [], options = {})
      opts = {}
      options.each do |ks, v|
        k = ks.to_s
        opts[k] = Services::OptionValue.new(matrix: v) if /^\[\[.*\]\]$/.match?(v.to_s)
        opts[k] = Services::OptionValue.new(vector: v) if !opts[k] && v.to_s =~ /^\[.*\]$/
        opts[k] = Services::OptionValue.new(integer: v.to_i) if !opts[k] && v.to_s == v.to_i.to_s
        opts[k] = Services::OptionValue.new(number: v.to_f) if !opts[k] && v.to_s =~ /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/
        opts[k] = Services::OptionValue.new(str: v.to_s) unless opts[k]
      end
      cspecs = cstr_specs.map do |cspec|
        Services::ConstraintSpec.new(type: CSTRS_TYPES[cspec[:type]] || "?", bound: cspec[:bound])
      end
      _send { @client.create_optimizer(@id, optimizer_kind, xlimits, cspecs.compact, opts) }
    end

    def ask
      res = nil
      _send { res = @client.ask(@id) }
      res
    end

    def tell(x, y)
      _send {
        @client.tell(@id, x, y)
      }
    end

    def destroy_optimizer
      _send { @client.destroy_optimizer(@id) }
    end
  end
end
