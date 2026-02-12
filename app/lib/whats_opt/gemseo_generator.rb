# frozen_string_literal: true

require "whats_opt/code_generator"
require "whats_opt/server_generator"

module WhatsOpt
  class GemseoGenerator < WhatsOpt::CodeGenerator
    DEFAULT_DOE_DRIVER = :smt_doe_lhs
    DEFAULT_OPTIMIZATION_DRIVER = :scipy_optimizer_slsqp

    class DisciplineNotFoundException < StandardError
    end

    class NotYetImplementedError < StandardError
    end

    def initialize(mda, pkg_format: false)
      super(mda, pkg_format: pkg_format)
      @prefix = "gemseo"
      @framework = "gemseo"
    end

    # sqlite_filename: nil, with_run: true, with_server: true, with_runops: true
    def _generate_code(gendir, options = {})
      opts = { with_server: false, with_run: true, with_unittests: false, with_src_dir: false }.merge(options)
      if opts[:with_src_dir]
        src_dir = File.join(gendir, "src")
        Dir.mkdir(src_dir) unless Dir.exist?(src_dir)
      else
        src_dir = gendir
      end
      pkg_dir = package_dir? ? File.join(src_dir, @impl.py_modulename) : src_dir
      Dir.mkdir(pkg_dir) unless Dir.exist?(pkg_dir)

      @mda.disciplines.nodes.each do |disc|
        if disc.has_sub_analysis?
          raise NotYetImplementedError.new("Cannot generate code for sub_analysis #{disc.name}")
          _generate_sub_analysis(disc, pkg_dir, opts)
        else
          _generate_discipline(disc, pkg_dir, opts)
          raise NotYetImplementedError.new("Cannot generate code for unit test #{disc.name}") if opts[:with_unittests]
        end
      end
      _generate_main(pkg_dir, opts)
      _generate_run_scripts(gendir, opts)
      if opts[:with_server] || (!@check_only && @mda.has_remote_discipline?(@remote_ip))
        raise NotYetImplementedError.new("Cannot generate code for server")
      end
      if opts[:with_egmdo] || @driver_name =~ /egmdo|egdoe/
        raise NotYetImplementedError.new("Cannot generate code for egmdo")
      end
      if package_dir? && @framework == "gemseo"
        _generate_package_files(gendir)
      end

      @genfiles
    end

    def _generate_discipline(discipline, gendir, options = {})
      @discipline = discipline  # @discipline used in template
      @with_server = options[:with_server]
      _generate(discipline.impl.py_filename, "gemseo/gemseo_discipline.py.erb", gendir)
      _generate(discipline.impl.py_basefilename, "gemseo/gemseo_discipline_base.py.erb", gendir)
    end

    def _generate_main(gendir, options = {})
      _generate(@impl.py_filename, "gemseo/gemseo_analysis.py.erb", gendir)
      _generate(@impl.py_basefilename, "gemseo/gemseo_analysis_base.py.erb", gendir)
      _generate("__init__.py", "__init__.py.erb", gendir)
    end

    # options: with_runops: true, with_run: true
    def _generate_run_scripts(gendir, options = {})
      if options[:with_run]
        _generate("mda_init.py", "mda_init.py.erb", gendir)
        _generate("run_mda.py", "gemseo/run_mda.py.erb", gendir)
      end
      if (options[:with_runops] || @mda.is_root_analysis?) && @mda.has_decision_variables?
        if @mda.is_root_analysis? && @mda.has_objective?
          _generate("run_doe.py", "gemseo/run_doe.py.erb", gendir)
          _generate("run_mdo.py", "gemseo/run_mdo.py.erb", gendir)
        end
      end
    end

    def _generate_package_files(gendir)
      _generate(".gitignore", "package/gitignore.erb", gendir, no_comment: true)
      _generate("README.md", "package/README.md.erb", gendir, no_comment: true)
      _generate("pyproject.toml", "package/pyproject.toml.erb", gendir, no_comment: true)
    end
  end
end
