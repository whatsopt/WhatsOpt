import os
import numpy as np
import re
import csv
import tempfile

from segomoe.sego import Sego
from segomoe.constraint import Constraint


class SegomoeOptimizer(object):
    def __init__(self, xlimits):
        self.constraint_handling = "MC"  # or 'UTB'
        self.xlimits = xlimits
        self.workdir = tempfile.TemporaryDirectory()

    def ask(self):
        res = self.sego.run_optim(n_iter=1)
        return res

    def tell(self, x, y):

        nx = x.shape[1]
        ny = y.shape[1]
        obj = y[:, :1]
        cstrs = y[:, 1:]

        print("Bounds of design variables:")
        print(self.xlimits)

        lb = self.xlimits[:, 0].tolist()
        ub = self.xlimits[:, 1].tolist()

        def f_grouped(x):
            return np.zeros(ny), False

        var = [{"name": "x_" + str(i), "lb": lb[i], "ub": ub[i]} for i in range(nx)]

        mod_obj = {
            "type": "Krig",
            "corr": "squared_exponential",
            "theta0": [1.0] * nx,
            "thetaL": [0.1] * nx,
            "thetaU": [10.0] * nx,
        }
        mod_con = mod_obj
        default_models = {"obj": mod_obj, "con": mod_con}

        print(var)

        with tempfile.TemporaryDirectory() as tmpdir:
            np.save(os.path.join(tmpdir, "doe"), x)
            np.save(os.path.join(tmpdir, "doe_response"), y)
            self.sego = Sego(
                f_grouped,
                var,
                const=[],
                optim_settings={
                    "model_type": default_models,
                    "n_clusters": 1,
                    "grouped_eval": True,
                    "analytical_diff": True,
                    "profiling": False,
                    "debug": False,
                    "verbose": False,
                    "cst_hand": self.constraint_handling,
                },
                path_hs=tmpdir,
                comm=None,
            )

