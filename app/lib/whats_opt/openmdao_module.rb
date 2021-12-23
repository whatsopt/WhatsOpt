# frozen_string_literal: true

require "whats_opt/string"

module WhatsOpt
  module OpenmdaoModule
    using WhatsOpt

    cattr_reader :root_modulename
    @@root_modulename = ""

    def basename
      "#{self.name.snakize}"
    end

    def camelname
      basename.camelize
    end

    def namespace
      namespace = self.path.map { |a| a.basename }
      namespace.shift
      namespace.join(".")
    end

    def packagename
      self.namespace.sub(/^#{Regexp.escape(@@root_modulename)}\.?/, "")
    end

    def full_modulename
      fmn = packagename
      fmn += "." unless fmn.blank?
      fmn += "#{basename}"
      fmn
    end

    def snake_modulename
      full_modulename.tr(".", "_")
    end

    def camel_modulename
      snake_modulename.camelize
    end

    def py_modulename
      basename
    end

    def py_packagename
      packagename
    end

    def py_full_modulename
      full_modulename
    end

    def set_as_root_module
      @@root_modulename = self.namespace
    end
    def unset_root_module
      @@root_modulename = ""
    end

    def py_classname
      camelname
    end

    def py_filename
      "#{basename}.py"
    end

    def py_basefilename
      "#{basename}_base.py"
    end
  end
end
