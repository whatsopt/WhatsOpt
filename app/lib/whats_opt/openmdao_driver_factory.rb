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
        @options[k] = v.to_s
        if ["true", "false"].include?(@options[k])
          @options[k] = @options[k].capitalize  # Python boolean
        elsif /\b[a-zA-Z]/.match?(@options[k]) # wrap string
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
                    egobox_optimizer_egor: { maxiter: "maxiter",  n_clusters: "n_clusters",  cstr_tol: "cstr_tol" }
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
      @lib =~ /pyoptsparse/
    end

    def scipy?
      @lib =~ /scipy/
    end

    def simplega?
      @lib =~ /simplega/
    end

    def onerasego?
      @lib =~ /onerasego/
    end

    def egobox?
      @lib =~ /egobox/
    end

  end

  class OpenmdaoDriverFactory
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
      egobox_optimizer_egor: { maxiter: 100, n_clusters: 1, cstr_tol: 1e-3 }
    }
    ALGO_NAMES = DEFAULT_OPTIONS.keys.sort

    class BadOptionError < StandardError
    end

    def initialize(algoname = :scipy_optimizer_slsqp, options_hash = {})
      @algoname = algoname.to_sym
      _initialize_options_dict(options_hash)
    end

    def create_driver
      if /doe/.match?(@algoname)
        OpenmdaoDoeDriver.new(@algoname, @dict[@algoname])
      elsif /optimizer/.match?(@algoname)
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
          if k =~ /^(\w+)_(\w+)$/
            algo, optname = $1.to_sym, $2.to_sym
            if algo != @algoname
              # p "Option #{k} is not a valid for algorithm #{@algoname}"
              raise BadOptionError.new("Option #{k} is not a valid for algorithm #{@algoname}")
            end
            @dict[@algoname][optname] = v
          else
            raise BadOptionError.new("Option #{k} is not valid: Option name should match /^(\w+)_(\w+)$/")
          end
        end

        DEFAULT_OPTIONS[@algoname].each do |optname, defaultval|
          @dict[@algoname][optname] ||= defaultval
        end
      end
  end
end
