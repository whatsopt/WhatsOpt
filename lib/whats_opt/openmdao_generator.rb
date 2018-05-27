require 'whats_opt/code_generator'

module WhatsOpt
  class OpenmdaoGenerator < CodeGenerator
    
    class DisciplineNotFoundException < StandardError
    end
    
    def initialize(mda)
      super(mda)
      @prefix = "openmdao"
    end
                    
    def check_mda_setup
      ok, lines = false, []
      Dir.mktmpdir("check_#{@mda.basename}_") do |dir|
        _generate_code dir
        ok, log = _check_mda dir   
        lines = log.lines.map(&:chomp)     
      end
      return ok, lines
    end
    
    def _generate_code(gendir, only_base=false)
      @mda.disciplines.nodes.each do |disc|
        _generate_discipline(disc, gendir, only_base)
      end 
      _generate_main(gendir, only_base)
      _generate_run_scripts(gendir)
    end
        
    def _check_mda(gendir)
      script = File.join(gendir, @mda.py_filename) 
      stdouterr, status = Open3.capture2e(PYTHON, script, '--no-n2')
      return status.success?, stdouterr
    end

    def _generate_discipline(discipline, gendir, only_base=false)
      @discipline=discipline  # @discipline used in template
      _generate(discipline.py_filename, 'openmdao_discipline.py.erb', gendir) unless only_base
      _generate(discipline.py_basefilename, 'openmdao_discipline_base.py.erb', gendir)
    end
    
    def _generate_main(gendir, only_base=false)
      _generate(@mda.py_filename, 'openmdao_main.py.erb', gendir) unless only_base
      _generate(@mda.py_basefilename, 'openmdao_main_base.py.erb', gendir)
    end    
       
    def _generate_run_scripts(gendir)
      _generate('run_analysis.py', 'run_analysis.py.erb', gendir)
      _generate('run_doe.py', 'run_doe.py.erb', gendir)
      _generate('run_screening.py', 'run_screening.py.erb', gendir)
      _generate('run_optimization.py', 'run_optimization.py.erb', gendir)
    end    
  end
end
