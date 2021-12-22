# frozen_string_literal: true

require "whats_opt/code_generator"

module WhatsOpt
  class ServerGenerator < CodeGenerator
    THRIFT_COMPILER = APP_CONFIG["thrift_cmd"] || "thrift"
    THRIFT_FILE = "analysis.thrift"

    class ThriftError < StandardError
    end

    def initialize(mda, server_host: nil, remote_ip: "", pkg_format: false)
      super(mda, pkg_format: pkg_format)
      @server_host = server_host
      @remote = !server_host.nil?
      @prefix = "remote_server"
      @comment_delimiters = { begin: "/*", end: "*/" }
      @remote_ip = remote_ip
    end

    def _generate_code(gendir, options = {})
      pkg_dir = @pkg_format ? File.join(gendir, @mda.py_modulename) : gendir
      Dir.mkdir(pkg_dir) unless Dir.exist?(pkg_dir)
      server_dir = File.join(pkg_dir, @server_module)
      Dir.mkdir(server_dir) unless File.exist?(server_dir)
      ok, log = _generate_with_thrift(server_dir)
      @comment_delimiters = { begin: '"""', end: '"""' }
      raise ThriftError.new(log) if !ok
      _generate("#{@mda.basename}_conversions.py", "thrift/analysis_conversions.py.erb", server_dir)
      _generate("discipline_proxy.py", "thrift/discipline_proxy.py.erb", server_dir)
      if @mda.is_root?
        _generate("#{@mda.basename}_proxy.py", "thrift/analysis_proxy.py.erb", server_dir) 
        _generate("remote_discipline.py", "thrift/remote_discipline.py.erb", server_dir)
        _generate("run_server.py", "thrift/run_server.py.erb", gendir) 
      end
    end

    def _generate_with_thrift(gendir)
      _generate(THRIFT_FILE, "thrift/#{THRIFT_FILE}.erb", gendir)
      thrift_file = File.join(gendir, THRIFT_FILE)
      stdouterr, status = Open3.capture2e(THRIFT_COMPILER, "-out", "#{gendir}", "-gen", "py", thrift_file)
      if status.success?
        modul = @mda.py_modulename
        klass = @mda.camel_modulename
        thrift_files = ["__init__.py", "#{modul}/__init__.py", "#{modul}/#{klass}-remote", "#{modul}/#{klass}.py",
                        "#{modul}/constants.py", "#{modul}/ttypes.py"]
        @genfiles += thrift_files.map { |f| File.join(gendir, f) }
      end
      return status.success?, stdouterr
    end
  end
end
