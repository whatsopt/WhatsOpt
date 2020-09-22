# frozen_string_literal: true

require "json"

module WhatsOpt
  class MdajsonGenerator

    def initialize(mda)
      @mda = mda
    end

    def generate
      as_json = AnalysisAttrsSerializer.new(@mda).as_json

      as_json.to_json
    end

  end
end
