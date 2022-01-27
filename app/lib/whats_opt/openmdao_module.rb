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

    def sub_packagename
      self.namespace.sub(/^#{Regexp.escape(@@root_modulename)}\.?/, "")
    end

    def modulename
      basename
    end

    def full_modulename(final_name: modulename)
      fmn = sub_packagename
      fmn += "." unless fmn.blank?
      fmn += "#{final_name}"
      fmn
    end

    def snake_modulename
      full_modulename.tr(".", "_")
    end

    def camel_modulename
      snake_modulename.camelize
    end

    def py_sub_packagename
      sub_packagename
    end

    def py_modulename
      modulename
    end

    def py_full_modulename
      full_modulename(final_name: py_modulename)
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
