require 'whats_opt/code_generator'
require 'whats_opt/server_generator'

module WhatsOpt
  class OpenmdaoGenerator < CodeGenerator
    
    DEFAULT_DOE_DRIVER = :smt_doe_lhs
    DEFAULT_OPTIMIZATION_DRIVER = :scipy_optimizer_slsqp
    
    class DisciplineNotFoundException < StandardError
    end
    
    def initialize(mda, server_host=nil, driver_name=nil, driver_options={})
      super(mda, server_host)
      @prefix = "openmdao"
      @remote = !server_host.nil?
      @sgen = WhatsOpt::ServerGenerator.new(mda, server_host)
      @sqlite_filename = 'cases.sqlite'
      @driver_name = driver_name.to_sym if driver_name
      @driver_options = driver_options
    end
                    
    def check_mda_setup
      ok, lines = false, []
      Dir.mktmpdir("check_#{@mda.basename}_") do |dir|
        begin
          _generate_code dir
        rescue ServerGenerator::ThriftError => e
          ok = false
          lines = e.to_s.lines.map(&:chomp)
        else
          ok, log = _check_mda dir   
          lines = log.lines.map(&:chomp)
        end     
      end
      return ok, lines
    end
             
    def run(method="analysis", sqlite_filename=nil)
      ok, lines = false, []
      Dir.mktmpdir("run_#{@mda.basename}_#{method}") do |dir|
        begin
          _generate_code dir, sqlite_filename: sqlite_filename
        rescue ServerGenerator::ThriftError => e
          ok = false
          lines = e.to_s.lines.map(&:chomp)
        else
          ok, log = _run_mda(dir, method)   
          lines = log.lines.map(&:chomp)
        end
      end
      return ok, lines
    end
    
    def monitor(method="analysis", sqlite_filename=nil, &block)
      ok, lines = false, []
      Dir.mktmpdir("run_#{@mda.basename}_#{method}") do |dir|
        dir = '/tmp/'
        _generate_code dir, sqlite_filename: sqlite_filename
        _monitor_mda(dir, method, &block)   
      end
    end
    
    def _check_mda(dir)
      script = File.join(dir, @mda.py_filename) 
      Rails.logger.info "#{PYTHON} #{script} --no-n2"
      stdouterr, status = Open3.capture2e(PYTHON, script, '--no-n2')
      return status.success?, stdouterr
    end
    
    def _run_mda(dir, method)
      script = File.join(dir, "run_#{method}.py")
      Rails.logger.info "#{PYTHON} #{script}"
      stdouterr, status = Open3.capture2e(PYTHON, script, '--batch')
      return status.success?, stdouterr
    end
    
    def _monitor_mda(dir, method, &block)
      script = File.join(dir, "run_#{method}.py")
      Rails.logger.info "#{PYTHON} #{script}"
      Open3.popen2e(PYTHON, script, '--batch', &block)
    end
    
    def _generate_code(gendir, only_base: false, sqlite_filename: nil)
      @mda.disciplines.nodes.each do |disc|
        _generate_discipline(disc, gendir, only_base)
      end 
      _generate_main(gendir, only_base)
      _generate_run_scripts(gendir, sqlite_filename)
      @sgen._generate_code(gendir)
      @genfiles += @sgen.genfiles
    end
     
    def _generate_discipline(discipline, gendir, only_base=false)
      @discipline=discipline  # @discipline used in template
      _generate(discipline.py_filename, 'openmdao_discipline.py.erb', gendir) unless only_base
      _generate(discipline.py_basefilename, 'openmdao_discipline_base.py.erb', gendir)
    end
    
    def _generate_main(gendir, only_base)
      _generate(@mda.py_filename, 'openmdao_main.py.erb', gendir) unless only_base
      _generate(@mda.py_basefilename, 'openmdao_main_base.py.erb', gendir)
    end    
       
    def _generate_run_scripts(gendir, sqlite_filename=nil)
      _generate('run_analysis.py', 'run_analysis.py.erb', gendir)
      if @driver_name
        @driver = OpenmdaoDriverFactory.new(@driver_name, @driver_options).create_driver
        if @driver.optimization?
          @sqlite_filename = sqlite_filename || "#{@mda.basename}_optimization.sqlite"
          _generate('run_optimization.py', 'run_optimization.py.erb', gendir)
        else
          @sqlite_filename = sqlite_filename || "#{@mda.basename}_doe.sqlite"
          _generate('run_doe.py', 'run_doe.py.erb', gendir)
        end
      else
        @driver = OpenmdaoDriverFactory.new(DEFAULT_DOE_DRIVER).create_driver
        @sqlite_filename = sqlite_filename || "#{@mda.basename}_doe.sqlite"
        _generate('run_doe.py', 'run_doe.py.erb', gendir)
        @driver = OpenmdaoDriverFactory.new(DEFAULT_OPTIMIZATION_DRIVER).create_driver
        @sqlite_filename = sqlite_filename || "#{@mda.basename}_optimization.sqlite"
        _generate('run_optimization.py', 'run_optimization.py.erb', gendir)        
      end
      @sqlite_filename = sqlite_filename || "#{@mda.basename}_screening.sqlite"
      _generate('run_screening.py', 'run_screening.py.erb', gendir)
    end    
  end
end
