# frozen_string_literal: true

module WhatsOpt
  refine String do
    def snakize
      gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
      gsub(/([a-z\d])([A-Z])/, '\1_\2').
      tr("-.", "_").
      gsub(/\s/, "_").
      gsub(/__+/, "_").
      downcase
    end
  end

  refine TrueClass do
    def py_boolean
      "True"
    end
  end

  refine FalseClass do
    def py_boolean
      "False"
    end
  end
end
