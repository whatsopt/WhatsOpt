module WhatsOpt  
  class RemoteServerGenerator < CodeGenerator
    
    THRIFT_COMPILER = APP_CONFIG['thrift_cmd'] || "thrift"
    THRIFT_FILE = 'analysis.thrift'
      
    def initialize(mda)
      super(mda)
      @prefix='remote_server'
    end
                        
    def _generate_code(gendir, only_base=false)
      _generate(THRIFT_FILE, "#{THRIFT_FILE}.erb", gendir)
      _generate_with_thrift(gendir)
      _generate("#{@mda.basename}_conversions.py", 'analysis_conversions.erb', gendir) unless only_base
      _generate("#{@mda.basename}_server.py", 'analysis_server.erb', gendir) unless only_base
    end    
    
    def _generate_with_thrift(gendir)
      script = File.join(gendir, THRIFT_FILE) 
      stdouterr, status = Open3.capture2e(THRIFT_COMPILER, script, '-out', "#{gendir}/server", '-gen', 'py', THRIFT_FILE)
      return status.success?, stdouterr
    end
  end  
end
