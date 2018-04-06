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
        self.options.declare('grid_step_size', types=int , default=2,
                             desc='grid jump size')
        self.options.update(kwargs)

    def _setup_driver(self, problem):
        super(SalibDoeDriver, self)._setup_driver(problem)
        n_trajs = self.options['n_trajs']
        n_levels = self.options['n_levels']
        grid_jump = self.options['grid_step_size']

        bounds=[]
        names=[]
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
                    
                display_name = name.split('.')[-1]
                if size>1:
                    display_name += str(j)
                names.append(display_name)
                bounds.append((p_low, p_high))

        self._pb = {'num_vars': len(names), 
                    'names': names, 
                    'bounds': bounds, 'groups': None}
        self._cases = ms.sample(self._pb, n_trajs, n_levels, grid_jump)

    def get_cases(self):
        return self._cases

    def get_salib_problem(self):
        return self._pb

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

