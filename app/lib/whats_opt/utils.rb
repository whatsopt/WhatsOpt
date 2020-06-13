# frozen_string_literal: true

require "yaml"

module WhatsOpt
  module Utils
    def shape_of(str)
      if /\[(.*)\]/.match?(str)
        ary = YAML.load(str)
        "(#{ary.size},#{_dim(ary.first)})"
      else
        "1"
      end
    end

    private
      def _dim(ary)
        if ary.is_a? Array
          res = "#{ary.size}"
          sub = _dim(ary.first)
          unless sub.blank?
            res += ",#{sub}"
          end
          res
        else
          ""
        end
      end
  end
end
