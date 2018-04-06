"""
Simple driver for running model on design of experiments cases using Salib sampling methods
"""
from __future__ import print_function
from six import itervalues, iteritems, reraise
from six.moves import range

import numpy as np

from openmdao.core.driver import Driver, RecordingDebugging
from SALib.sample import morris as ms

class SalibDoeDriver(Driver):
    """
    Baseclass for SALib design-of-experiments Drivers
    """

    def __init__(self, **kwargs):
        super(SalibDoeDriver, self).__init__()

        self.options.declare('n_trajs', types=int, default=100,
                             desc='number of trajectories to apply morris method')
        self.options.declare('n_levels', types=int, default=4,
                             desc='number of grid levels')
        self.options.update(kwargs)

    def _setup_driver(self, problem):
        super(SalibDoeDriver, self)._setup_driver(problem)
        n_trajs = self.options['n_trajs']
        n_levels = self.options['n_levels']

        bounds=[]
        names=[]
        for name, meta in iteritems(self._designvars):
            size = meta['size']
            meta_low = meta['lower']
            meta_high = meta['upper']
            for j in range(size):
                name_var=name
                if isinstance(meta_low, np.ndarray):
                    p_low = meta_low[j]
                    name_var += "_"+str(j)
                else:
                    p_low = meta_low

                if isinstance(meta_high, np.ndarray):
                    p_high = meta_high[j]
                else:
                    p_high = meta_high
                    
                names.append(name_var)
                bounds.append((p_low, p_high))

        self.pb = {'num_vars': len(names), 
                   'names': names, 
                   'bounds': bounds, 'groups': None}

        print(self.pb)

        self._cases = ms.sample(self.pb, n_trajs, n_levels, grid_jump=2)
        print(self._cases)

    def get_cases(self):
        return self._cases

    def run(self):
        """
        Execute the Problem for each generated cases.
        """
        model = self._problem.model
        self.iter_count = 0

        for i in range(self._cases.shape[0]):
            j=0
            for name, meta in iteritems(self._designvars):
                size = meta['size']
                self.set_design_var(name, self._cases[i, j:j + size])
                j += size

            with RecordingDebugging("Morris", self.iter_count, self) as rec:
                self.iter_count += 1
                model._solve_nonlinear()

