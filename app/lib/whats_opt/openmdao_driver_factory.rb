# frozen_string_literal: true

module WhatsOpt
  class OpenmdaoDriver
    attr_reader :lib, :algo, :options

    def initialize(algoname, options)
      @algoname = algoname.to_sym
      @algoname =~ /^(\w+)_(\w+)$/
      @lib, @algo = $1, $2
      @options = {}

      options.each do |k, v|
        @options[k] = v
        if ["true", "false"].include?(@options[k].to_s)
          @options[k] = @options[k].to_s.capitalize  # Python boolean
        elsif @options[k].kind_of?(Array)
          @options[k] = @options[k].join(".")
        elsif /\b[a-zA-Z]/.match?(@options[k].to_s) # wrap string
          @options[k] = "'#{@options[k]}'"
        end
      end
    end

    def algo_option
      @algo.upcase
    end

    def optimization?
      false
    end

    def doe?
      false
    end
  end

  class OpenmdaoRunOnceDriver < OpenmdaoDriver
  end

  class OpenmdaoDoeDriver < OpenmdaoDriver
    def doe?
      true
    end
  end

  class OpenmdaoOptimizerDriver < OpenmdaoDriver
    attr_reader :opt_settings

    # Option pattern: <library>_optimizer_<algoname>_<option_name>
    OPT_SETTINGS = {
                    scipy_optimizer_cobyla: {},
                    scipy_optimizer_bfgs: {},
                    scipy_optimizer_slsqp: {},
                    pyoptsparse_optimizer_conmin: {},
                    pyoptsparse_optimizer_fsqp: {},
                    pyoptsparse_optimizer_slsqp: {},
                    pyoptsparse_optimizer_psqp: {},
                    pyoptsparse_optimizer_nsga2: {},
                    pyoptsparse_optimizer_snopt: { tol: "Major feasibility tolerance",
                                                   maxiter: "Major iterations limit" },
                    onerasego_optimizer_segomoe: { maxiter: "maxiter", ncluster: "n_clusters",
                                                   optimizer: "optimizer", doedim: "size_doe" },
                    onerasego_optimizer_egmdo: { maxiter: "maxiter", ncluster: "n_clusters",
                                                 optimizer: "optimizer", doedim: "size_doe" },
                    egobox_optimizer_egor: { maxiter: "maxiter",  n_clusters: "n_clusters",
                                             infill_strategy: "infill_strategy",
                                             infill_optimizer: "infill_optimizer",
                                             cstr_tol: "cstr_tol", regr_spec: "regr_spec", corr_spec: "corr_spec" }
                   }

    # optimizer specific settings
    def initialize(algoname, options)
      super(algoname, options)
      @opt_settings = {}
      unless OPT_SETTINGS[algoname]
        raise "Algoname #{algoname} not in #{OPT_SETTINGS.keys}"
      end
      options.each do |k, _|
        if OPT_SETTINGS[@algoname][k]
          # option of the optimizer, to be set in opt_settings dict
          # and removed from options of the driver
          @opt_settings[OPT_SETTINGS[@algoname][k]] = @options[k]
          @options.delete(k)
        end
      end
    end

    def algo_option
      if onerasego?
        "SEGOMOE"
      elsif egobox?
        "EGOR"
      else
        super
      end
    end

    def optimization?
      true
    end

    def doe?
      false
    end

    def pyoptsparse?
      @lib && @lib.include?("pyoptsparse")
    end

    def scipy?
      @lib && @lib.include?("scipy")
    end

    def simplega?
      @lib && @lib.include?("simplega")
    end

    def onerasego?
      @lib && @lib.include?("onerasego")
    end

    def egobox?
      @lib && @lib.include?("egobox")
    end
  end

  class OpenmdaoDriverFactory
    # Option pattern: <library>_<optimizer|doe>_<algoname>_<option_name>
    DEFAULT_OPTIONS = {
      runonce: {},
      smt_doe_lhs: { nbpts: 50 },
      smt_doe_egdoe: { nbpts: 50 },
      scipy_optimizer_cobyla: {},
      scipy_optimizer_bfgs: {},
      scipy_optimizer_slsqp: { tol: 1e-6, maxiter: 100, disp: true },
      pyoptsparse_optimizer_conmin: {},
      pyoptsparse_optimizer_fsqp: {},
      pyoptsparse_optimizer_slsqp: {},
      pyoptsparse_optimizer_psqp: {},
      pyoptsparse_optimizer_nsga2: {},
      pyoptsparse_optimizer_snopt: { tol: 1e-6, maxiter: 100 },
      onerasego_optimizer_segomoe: { maxiter: 100, ncluster: 1, optimizer: "slsqp" },
      onerasego_optimizer_egmdo: { maxiter: 100, ncluster: 1, optimizer: "slsqp" },
      egobox_optimizer_egor: { maxiter: 20, n_clusters: 1,
                               infill_strategy: ["egx", "InfillStrategy", "WB2"],
                               infill_optimizer: ["egx", "InfillOptimizer", "SLSQP"],
                               regr_spec: ["egx", "RegressionSpec", "CONSTANT"],
                               corr_spec: ["egx", "CorrelationSpec", "SQUARED_EXPONENTIAL"]
                              }
    }
    ALGO_NAMES = DEFAULT_OPTIONS.keys.sort

    class BadOptionError < StandardError
    end

    def initialize(algoname = :scipy_optimizer_slsqp, options_hash = {})
      @algoname = algoname.to_sym
      _initialize_options_dict(options_hash)
    end

    def create_driver
      if @algoname && @algoname.to_s.include?("doe")
        OpenmdaoDoeDriver.new(@algoname, @dict[@algoname])
      elsif @algoname && @algoname.to_s.include?("optimizer")
        OpenmdaoOptimizerDriver.new(@algoname, @dict[@algoname])
      else
        OpenmdaoRunOnceDriver.new(@algoname, @dict[@algoname])
      end
    end

    private
      def _initialize_options_dict(options_hash)
        @dict = {}
        unless ALGO_NAMES.include?(@algoname)
          raise BadOptionError.new("Algorithm '#{@algoname}' should be in #{ALGO_NAMES}")
        end
        @dict[@algoname] = {}
        options_hash.each do |k, v|
          if k =~ /^([a-z]+_[a-z]+_[a-z]+)_(\w+)$/
            algo, optname = $1.to_sym, $2.to_sym
            if algo != @algoname
              raise BadOptionError.new("Option #{k} is not a valid for algorithm #{@algoname}")
            end
            @dict[@algoname][optname] = v
          else
            raise BadOptionError.new("Option #{k} is not valid: Option name should match /^([a-z]+_[a-z]+_[a-z]+)_(\w+)$/")
          end
        end

        DEFAULT_OPTIONS[@algoname].each do |optname, defaultval|
          @dict[@algoname][optname] ||= defaultval
        end
      end
  end
end
