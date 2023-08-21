# frozen_string_literal: true

require "thrift"
require "optimizer_store"

module WhatsOpt
  class OptimizationProxyError < Exception; end

  class OptimizerProxy < ServiceProxy
    CSTRS_TYPES = {
      "<" => WhatsOpt::Services::ConstraintType::LESS,
      "=" => WhatsOpt::Services::ConstraintType::EQUAL,
      ">" => WhatsOpt::Services::ConstraintType::GREATER,
    }

    XTYPE_TYPES = {
      'float_type' => WhatsOpt::Services::Type::FLOAT,
      'int_type' => WhatsOpt::Services::Type::INT,
      'ord_type' => WhatsOpt::Services::Type::ORD,
      'enum_type' => WhatsOpt::Services::Type::ENUM,
    }

    def _initialize
      @protocol = Thrift::MultiplexedProtocol.new(
        @protocol, "OptimizerStoreService"
      )
      @client = Services::OptimizerStore::Client.new(@protocol)
    end

    def create_optimizer(optimizer_kind, xlimits, cstr_specs = [], options = {})
      opts = _parse_options(options)
      cspecs = cstr_specs.map do |cspec|
        Services::ConstraintSpec.new(type: CSTRS_TYPES[cspec[:type]] || "?", bound: cspec[:bound])
      end
      _send { @client.create_optimizer(@id, optimizer_kind, xlimits, cspecs.compact, opts) }
    end

    def create_mixint_optimizer(optimizer_kind, xtypes, n_obj, cstr_specs = [], options = {})
      opts = _parse_options(options)
      cspecs = cstr_specs.map do |cspec|
        Services::ConstraintSpec.new(type: CSTRS_TYPES[cspec[:type]] || "?", bound: cspec[:bound])
      end
      xtyps = xtypes.map do |xt|
        limits = case xt['type']
                 when 'float_type'
                   flimits = WhatsOpt::Services::Flimits.new(lower: xt['limits'][0], upper: xt['limits'][1])
                   WhatsOpt::Services::Xlimits.flimits(flimits)
                 when 'int_type'
                   ilimits = WhatsOpt::Services::Ilimits.new(lower: xt['limits'][0], upper: xt['limits'][1])
                   WhatsOpt::Services::Xlimits.ilimits(ilimits)
                 when 'ord_type'
                   WhatsOpt::Services::Xlimits.olimits(xt['limits'])
                 when 'enum_type'
                   WhatsOpt::Services::Xlimits.elimits(xt['limits'])
                 else
                   raise OptimizationProxyError.new("Type should be float_type, int_type, ord_type or enum_type, got #{xt['type']}")
        end
        Services::Xtype.new(type: XTYPE_TYPES[xt['type']], limits: limits)
      end
      _send { @client.create_mixint_optimizer(@id, optimizer_kind, xtyps, n_obj, cspecs.compact, opts) }
    end

    def ask(with_best)
      res = nil
      _send { res = @client.ask(@id, with_best) }
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

  private
    def _parse_options(options)
      opts = {}
      options.each do |ks, v|
        k = ks.to_s
        opts[k] = Services::OptionValue.new(matrix: v) if /^\[\[.*\]\]$/.match?(v.to_s)
        opts[k] = Services::OptionValue.new(vector: v) if !opts[k] && v.to_s =~ /^\[.*\]$/
        opts[k] = Services::OptionValue.new(boolean: v) if v.class == TrueClass || v.class == FalseClass
        opts[k] = Services::OptionValue.new(integer: v.to_i) if !opts[k] && v.to_s == v.to_i.to_s
        opts[k] = Services::OptionValue.new(number: v.to_f) if !opts[k] && v.to_s =~ /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/
        opts[k] = Services::OptionValue.new(str: v.to_s) unless opts[k]
      end
      opts
    end
  end
end
