from __future__ import print_function
import numpy as np
from six import iteritems

from openmdao.core.driver import Driver, RecordingDebugging
from openmdao.core.analysis_error import AnalysisError
from openmdao.recorders.recording_iteration_stack import Recording

from segomoe.sego_defs import get_sego_options, ExitStatus
from segomoe.constraint import Constraint
from segomoe.sego import Sego

def to_list(l, size):
    if not (isinstance(l, np.ndarray) or isinstance(l, list)):
        return [l] * size
    diff_len = len(l) - size
    if diff_len > 0:
        return l[0:size]
    elif diff_len < 0:
        return [l[0]] * size
    else:
        return l

class SegoMoeDriver(Driver):
    """
    Driver for OpenMDAO framework
    """

    def __init__(self, **kwargs):
        """
        Initialize the driver with the following option.
        """
        super(SegoMoeDriver, self).__init__(**kwargs)

        # What we support
        self.supports['inequality_constraints'] = True
        self.supports['equality_constraints'] = True
        self.supports['two_sided_constraints'] = True
        self.supports['linear_constraints'] = True

        # What we don't support
        self.supports['multiple_objectives'] = False
        self.supports['active_set'] = False
        self.supports['integer_design_vars'] = False
        self.supports['simultaneous_derivatives'] = False
        self.supports['total_jac_sparsity'] = False
        self.supports['gradients'] = False


    def _declare_options(self):
        # Set the options from segomoe defs. Let sego check for option validity
        for opt, opt_dict in iteritems(get_sego_options()):
            self.options.declare(opt, opt_dict['default'], desc=opt_dict['desc'])

        # Add n_iter option
        self.options.declare('n_iter', 100, desc='Number of iterations to run')

    def _setup_driver(self, problem):
        super(SegoMoeDriver, self)._setup_driver(problem)
        
        self.comm = None
        


    def run(self, path_hs='', eq_tol={}, ieq_tol={}):
        """
        Optimize the problem using SEGOMOE.

        Parameters
        ----------
        problem : Problem object
            An optimization problem of OpenMDAO framework
        path_hs: string, optional
            path to a directory storing hot_start data
        eq_tol: dict
            Dictionary to define specific tolerance for eq constraints
            {'[groupName]': [tol]} Default tol = 1e-5
        ieq_tol: dict
            Dictionary to define specific tolerance for ieq constraints
            {'[groupName]': [tol]} Default tol = 1e-5
        """

        model = self._problem.model
        path_hs=''
        self.eq_tol=eq_tol
        self.ieq_tol=ieq_tol
        self.iter_count = 0
        self.name = optimizer = "onera_optimizer_segomoe"
        self._sego_vars = []
        self._sego_cons = []
        self._map_con = {}
        self._n_mapped_con = 0
        
        # Initial Run
        with RecordingDebugging(optimizer, self.iter_count, self) as rec:
            # Initial Run
            model._solve_nonlinear()
            rec.abs = 0.0
            rec.rel = 0.0
        self.iter_count += 1

        # Format design variables to suit segomoe implementation
        self._initialize_vars()
        
        # Format constraints to suit segomoe implementation
        self._initialize_cons()

        # Evaluation is necessarily grouped
        self.options['grouped_eval'] = True

        # Format option dictionary to suit SEGO implementation
        optim_settings = {key: self.options[key] for key in get_sego_options().keys()}

        # Instanciate a SEGO optimizer
        sego = Sego(self._objfunc, self._sego_vars, const=self._sego_cons, \
                    optim_settings=optim_settings, path_hs=path_hs, comm=self.comm)

        # Run the optim
        exit_flag, x_best, obj_best, dt_opt = sego.run_optim(n_iter=self.options['n_iter'])

        # Set optimal parameters
        i = 0
        for name, meta in iteritems(self._designvars):
            size = meta['size']
            self.set_design_var(name, x_best[i: i + size])
            i += size

        with RecordingDebugging(self.options['optimizer'], self.iter_count, self) as rec:
            model._solve_nonlinear()
            rec.abs = 0.0
            rec.rel = 0.0
        self.iter_count += 1

        self.exit_flag = (exit_flag == ExitStatus.valid_sol) or \
                         (exit_flag == ExitStatus.solution_reached)
                         
        return self.exit_flag

    def _initialize_vars(self):
        vars = []
        param_meta = self._designvars
        param_vals = self.get_design_var_values()
        for name, meta in iteritems(param_meta):
            if meta['size'] > 1:
                lower = meta['lower'] if np.isscalar(meta['lower']) else meta['lower'][i]
                upper = meta['upper'] if np.isscalar(meta['lower']) else meta['upper'][i]
                vars += [{'name': name + '_' + str(i),
                         'lb': lower,
                         'ub': upper} for i in range(meta['size'])]
            else:
                vars += [{'name': name, 'lb': meta['lower'], 'ub': meta['upper']}]
        self._sego_vars = vars

    def _initialize_cons(self):
        """
        Format OpenMDAO constraints to suit SEGOMOE implementation

        Parameters
        ----------
        eq_tol: dict
            Dictionary to define specific tolerance for eq constraints
            {'[groupName]': [tol]} Default tol = 1e-5
        ieq_tol: dict
            Dictionary to define specific tolerance for ieq constraints
            {'[groupName]': [tol]} Default tol = 1e-5
        """

        # for short
        add_con = self._sego_cons.append

        # Start at 1 -> obj first
        eval_index = 1

        con_meta = self._cons
        eq_cons = {name: con for name, con in iteritems(con_meta) if con['equals']}
        ieq_cons = {name: con for name, con in iteritems(con_meta) if not con['equals']}
        
        # Equality constraints
        for name in eq_cons.keys():
            meta = con_meta[name]
            size = meta['size']
            equals = to_list(meta['equals'], size)
            tol = to_list(eq_tol[name] if name in self.eq_tol else 1e-4, size)

            for k in xrange(size):
                add_con(Constraint('=', equals[k], name=(name + '_' + str(k)), \
                                   tol=tol[k]))
            # Map eq constraints - range to allow double-sided constraint support
            self._map_con[name] = range(eval_index, eval_index + size)
            eval_index += size
            self._n_mapped_con += size

        # Inequality constraints
        for name in ieq_cons.keys():
            meta = con_meta[name]
            size = meta['size']
            # Bounds - double sided is supported
            lower = to_list(meta['lower'], size)
            upper = to_list(meta['upper'], size)
            tol = to_list(ieq_tol[name] if name in self.ieq_tol else 1e-4, size)
            # Index list is updated for each real constraint to handle double sided constraints
            index_list = []

            for k in range(size):
                if lower[k] is None or lower[k] < -1e29:
                    # g(x) < upper
                    add_con(Constraint('<', upper[k], name=(name + '_' + str(k)), \
                                       tol=tol[k]))
                    index_list.append(eval_index)
                    eval_index += 1
                    self._n_mapped_con += 1
                elif upper[k] is None or upper[k] > 1e29:
                    # g(x) > lower
                    add_con(Constraint('>', lower[k], name=(name + '_' + str(k)), \
                                       tol=tol[k]))
                    index_list.append(eval_index)
                    eval_index += 1
                    self._n_mapped_con += 1
                else:
                    # lower < g(x) < upper
                    # Split is currently required for sego
                    add_con(Constraint('<', upper[k], name=(name + '_' + str(k) + '<'), \
                                       tol=tol[k]))
                    add_con(Constraint('>', lower[k], name=(name + '_' + str(k) + '>'), \
                                       tol=tol[k]))
                    index_list.append([eval_index, eval_index + 1])
                    eval_index += 2
                    self._n_mapped_con += 2
            self._map_con[name] = index_list
            
                
    def _objfunc(self, point):
        """
        Function that evaluates and returns the objective function and the
        constraints. This function is called by SEGOMOE

        Parameters
        ----------
        point : numpy.ndarray
            point to evaluate

        Returns
        -------
        func_dict : dict
            Dictionary of all functional variables evaluated at design point.
        fail : int
            0 for successful function evaluation
            1 for unsuccessful function evaluation
        """
        fail = False
        res = np.zeros(1 + self._n_mapped_con)
        model = self._problem.model

        try:
            # Pass in new parameters
            i = 0

            for name, meta in iteritems(self._designvars):
                size = meta['size']
                self.set_design_var(name, point[i: i + size])
                i += size

            # Execute the model
            with RecordingDebugging(self.options['optimizer'], self.iter_count, self) as rec:
                self.iter_count += 1
                try:
                    model._solve_nonlinear()

                    # Let the optimizer try to handle the error
                except AnalysisError:
                    model._clear_iprint()
                    fail = True

            # Get the objective function evaluation - single obj support
            for name, obj in iteritems(self.get_objective_values()):
                res[0] = obj

            # Get the constraint evaluations:
            for name, con_res in iteritems(self.get_constraint_values()):
                # Make sure con_res is array_like
                con_res = to_list(con_res, len(self._map_con[name]))
                # Perform mapping
                for i, con_index in enumerate(self._map_con[name]):
                    if isinstance(con_index, list):
                        # Double sided inequality constraint -> duplicate response
                        for k in con_index:
                            res[k] = con_res[i]
                    else:
                        res[con_index] = con_res[i]

        except Exception as msg:
            tb = traceback.format_exc()

            # Exceptions seem to be swallowed by the C code, so this
            # should give the user more info than the dreaded "segfault"
            print("Exception: %s" % str(msg))
            print(70 * "=", tb, 70 * "=")
            fail = True

        return res, fail
