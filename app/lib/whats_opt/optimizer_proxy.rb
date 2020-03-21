# frozen_string_literal: true

require "thrift"
require "optimizer_store"

module WhatsOpt
  class OptimizerProxy < ServiceProxy
    def _initialize
      @protocol = Thrift::MultiplexedProtocol.new(
        @protocol, "OptimizerStoreService"
      )
      @client = Services::OptimizerStore::Client.new(@protocol)
    end

    def create_optimizer(optimizer_kind, options={})
      opts = {}
      options.each do |ks, v|
        k = ks.to_s
        opts[k] = Services::OptionValue.new(matrix: v) if v.to_s =~ /^\[\[.*\]\]$/
        opts[k] = Services::OptionValue.new(vector: v) if (!opts[k] && v.to_s =~ /^\[.*\]$/)
        opts[k] = Services::OptionValue.new(integer: v.to_i) if (!opts[k] && v.to_s == v.to_i.to_s)
        opts[k] = Services::OptionValue.new(number: v.to_f) if (!opts[k] && v.to_s =~ /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/)
        opts[k] = Services::OptionValue.new(str: v.to_s) unless opts[k]
      end 
      _send { @client.create_optimizer(@id, optimizer_kind, opts) }
    end

    def ask()
      x_suggested = nil
      _send { x_suggested = @client.ask(@id) }
      x_suggested
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
