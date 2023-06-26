# frozen_string_literal: true

require "whats_opt/string"

module WhatsOpt
  module OpenmdaoModule
    using WhatsOpt

    cattr_reader :root_modulename
    @@root_modulename = ""

    def set_as_root_module
      @@root_modulename = self._namespace
    end
    def unset_root_module
      @@root_modulename = ""
    end

    def basename
      "#{self.name.snakize}"
    end

    def snake_modulename
      _full_modulename.tr(".", "_")
    end

    def camel_modulename
      snake_modulename.camelize
    end

    def py_sub_packagename
      _sub_packagename
    end

    def py_classname
      _classname
    end

    def py_modulename
      _modulename
    end

    def py_full_modulename
      _full_modulename(final_name: py_modulename)
    end

    def py_filename
      "#{basename}.py"
    end

    def py_optim_filename
      "#{basename}_optim.py"
    end

    def py_basefilename
      "#{basename}_base.py"
    end

  private

    def _modulename
      basename
    end

    def _classname
      basename.camelize
    end

    def _namespace
      namespace = self.path.map { |a| a.basename }
      namespace.shift
      namespace.join(".")
    end

    def _sub_packagename
      self._namespace.sub(/^#{Regexp.escape(@@root_modulename)}\.?/, "")
    end

    # return fully qualified dotted module name without root name 
    def _full_modulename(final_name: _modulename)
      fmn = _sub_packagename
      fmn += "." unless fmn.blank?
      fmn += "#{final_name}"
      fmn
    end

  end
end
