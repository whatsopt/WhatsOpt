# frozen_string_literal: true

module WhatsOpt
  module Discipline
    NULL_DRIVER_NAME = "__DRIVER__"

    # WhatsOpt / XDSMjs type mapping
    NULL_DRIVER = "null_driver"
    DISCIPLINE = "analysis"
    FUNCTION = "function"
    ANALYSIS = "mda"
    OPTIMIZATION = "mdo"

    TYPES = [NULL_DRIVER, DISCIPLINE, FUNCTION, ANALYSIS, OPTIMIZATION]
  end
end
