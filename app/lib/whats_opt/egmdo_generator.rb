# frozen_string_literal: true

require "whats_opt/code_generator"

module WhatsOpt
  class EgmdoGenerator < CodeGenerator

    def initialize(mda)
      super(mda)
      @prefix = "egmdo"
    end

    # sqlite_filename: nil, with_run: true, with_server: true, with_runops: true
    def _generate_code(gendir, options = {})
      egmdo_dir = File.join(gendir, @egmdo_module)
      Dir.mkdir(egmdo_dir) unless File.exist?(egmdo_dir)
      _generate("doe_factory.py", "egmdo/doe_factory.py.erb", egmdo_dir)
      _generate("gp_factory.py", "egmdo/gp_factory.py.erb", egmdo_dir)
      _generate("__init__.py", "__init__.py.erb", egmdo_dir)
    end

  end
end
