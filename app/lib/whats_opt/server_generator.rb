require 'whats_opt/code_generator'

module WhatsOpt  
  class ServerGenerator < CodeGenerator
    
    THRIFT_COMPILER = APP_CONFIG['thrift_cmd'] || "thrift"
    THRIFT_FILE = 'analysis.thrift'
      
    class ThriftError < StandardError
    end
    
    def initialize(mda, server_host=nil)
      super(mda, server_host)
      @prefix='remote_server'
      @comment_delimiters={begin: '/*', end: '*/'}
    end

    # FIXME: not happy with this interface as server generate always server and no nops
    def _generate_code(gendir, only_base: false, with_server: true, with_ops: false, sqlite_filename: nil)
      if with_server
        server_dir = File.join(gendir, @server_module)
        Dir.mkdir(server_dir) unless File.exists?(server_dir)
        ok, log = _generate_with_thrift(server_dir)
        @comment_delimiters={begin: '"""', end: '"""'}
        raise ThriftError.new(log) if !ok
        _generate("#{@mda.basename}_conversions.py", 'analysis_conversions.py.erb', server_dir)
        _generate("#{@mda.basename}_proxy.py", 'analysis_proxy.py.erb', server_dir)
        _generate("discipline_proxy.py", 'discipline_proxy.py.erb', server_dir)
        _generate("sub_analysis_proxy.py", 'sub_analysis_proxy.py.erb', server_dir)
        _generate("run_server.py", 'run_server.py.erb', gendir)
      end
    end    
    
    def _generate_with_thrift(gendir)
      _generate(THRIFT_FILE, "#{THRIFT_FILE}.erb", gendir)
      thrift_file = File.join(gendir, THRIFT_FILE)
      stdouterr, status = Open3.capture2e(THRIFT_COMPILER, '-out', "#{gendir}", '-gen', 'py', thrift_file)
      if status.success?
        modul = @mda.py_modulename
        klass = @mda.py_classname
        thrift_files = ['__init__.py', "#{modul}/__init__.py", "#{modul}/#{klass}-remote", "#{modul}/#{klass}.py",
                        "#{modul}/constants.py", "#{modul}/ttypes.py"]
        @genfiles += thrift_files.map{|f| File.join(gendir, f)}
      end
      return status.success?, stdouterr
    end
  end  
end
