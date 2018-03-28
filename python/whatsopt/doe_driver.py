"""
Simple driver for running model on design of experiments cases using SMT sampling methods
"""
from __future__ import print_function
from six import itervalues, iteritems, reraise
from six.moves import range

import numpy as np

from openmdao.core.driver import Driver, RecordingDebugging
from smt.sampling_methods import Clustered, FullFactorial, LHS, Random

_sampling_methods = {'Clustered': Clustered, 'FullFactorial': FullFactorial, 'LHS': LHS, 'Random': Random}

class DoeDriver(Driver):
    """
    Baseclass for design-of-experiments Drivers 
    """

    def __init__(self, **kwargs):
        super(DoeDriver, self).__init__()

        self.options.declare('sampling_method', 'LHS', values=_sampling_methods.keys(),
                             desc='Name of SMT sampling method used to generate doe cases')

        self.options.declare('n_cases', int,
                             desc='number of sampling cases to generate')
        self._method_name = None
        self._cases = None
        self.options.update(kwargs)

    def _setup_driver(self, problem):
        super(DoeDriver, self)._setup_driver(problem)
        self._method_name = self.options['sampling_method']
        self._n_cases = self.options['n_cases']

        xlimits=[]
        for name, meta in iteritems(self._designvars):
            size = meta['size']
            meta_low = meta['lower']
            meta_high = meta['upper']
            for j in range(size):
                if isinstance(meta_low, np.ndarray):
                    p_low = meta_low[j]
                else:
                    p_low = meta_low

                if isinstance(meta_high, np.ndarray):
                    p_high = meta_high[j]
                else:
                    p_high = meta_high

                xlimits.append((p_low, p_high))

        sampling = _sampling_methods[self._method_name](xlimits=np.array(xlimits))
        self._cases = sampling(self._n_cases)
        
    def get_cases(self):
        return self._cases
        
    def run(self):
        """
        Execute the Problem for each generated cases.
        """
        
        model = self._problem.model
        self.iter_count = 0
        
        for i in range(self._n_cases):
            j=0
            for name, meta in iteritems(self._designvars):
                size = meta['size']
                print(size)
                print(self._cases[i, j:j + size])
                self.set_design_var(name, self._cases[i, j:j + size])
                j += size
            
            with RecordingDebugging(self._method_name, self.iter_count, self) as rec:
                self.iter_count += 1
                model._solve_nonlinear()



