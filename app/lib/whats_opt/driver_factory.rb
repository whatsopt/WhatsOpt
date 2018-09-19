module WhatsOpt
  
  class Driver 
    attr_reader :lib, :algo, :options
    
    def initialize(algoname, options)
      @algoname = algoname
      @algoname =~ /^(\w+)_(\w+)$/
      @lib, @algo = $1, $2
      @options = {}
        
      options.each do |k, v| 
        @options[k] = v.to_s
        @options[k] = @options[k].capitalize if ["true", "false"].include?(@options[k]) 
      end
    end
  
    def doe?
      !optimization?
    end

    def algo_option
      @algo.upcase
    end    
    
    def pyoptsparse?
      @lib =~ /pyoptsparse/
    end
    
    def scipy?
      @lib =~ /scipy/
    end
    
    def simplega?
      @lib =~ /simplega/
    end
  end
  
  class OptimizerDriver < Driver 
    attr_reader :opt_settings
    
    OPT_SETTINGS = {scipy_optimizer_slsqp: {},
                    pyoptsparse_optimizer_snopt: {tol: "Major feasibility tolerance", 
                                                  maxiter: "Major iterations limit"}}
    
    # optimizer specific settings
    def initialize(algoname, options)
      super(algoname, options)
      
      @opt_settings = {}
      unless OPT_SETTINGS[algoname]
        raise "Algoname #{algoname} not in #{OPT_SETTINGS.keys}"
      end
      options.each do |k, _|
        if OPT_SETTINGS[@algoname][k]
          @opt_settings[OPT_SETTINGS[@algoname][k]] = @options[k]
          @options.delete(k)
        end
      end
    end
    
    def optimization?
      true
    end
  end

  class DoeDriver < Driver 
    def optimization?
      false
    end
  end
    
  class DriverFactory
    
    DEFAULT_OPTIONS = {
      scipy_optimizer_slsqp: {tol: 1e-6, maxiter: 100, disp: true},
      pyoptsparse_optimizer_snopt: {tol: 1e-6, maxiter: 100},
      smt_doe_lhs: {nbpts: 50},
    }
    ALGO_NAMES = DEFAULT_OPTIONS.keys.sort
    
    class BadOptionError < StandardError
    end
    
    def initialize(options_hash)
      @dict = {}
      _initialize(options_hash)
    end

    def create_driver
      if @algoname =~ /doe/
        DoeDriver.new(@algoname, @dict[@algoname])
      else
        OptimizerDriver.new(@algoname, @dict[@algoname])
      end
    end
    
    private 
    
    def _initialize(options_hash)
      options_hash.each do |k, v|
        if k =~ /^(\w+)_(\w+)$/  
          algo, optname = $1.to_sym, $2.to_sym
          unless ALGO_NAMES.include?(algo)
            raise BadOptionError.new("Algorithm #{algo} is not a valid: should be in #{ALGO_NAMES}") 
          end 
          if @algoname && algo != @algoname
            raise BadOptionError.new("Option #{k} is not a valid for algorithm #{@algoname}") 
          end
          @algoname ||= algo
          @dict[@algoname] ||= {}
          @dict[@algoname][optname] = v 
        else
          raise BadOptionError.new("Option #{k} is not a valid: Option name should match /^(\w+)_(\w+)$/")
        end
      end
      @algoname ||= :scipy_optimizer_slsqp
      @dict[@algoname] ||= {}
      DEFAULT_OPTIONS[@algoname].each do |optname, defaultval|
        @dict[@algoname][optname] ||= defaultval
      end
    end
  end
end