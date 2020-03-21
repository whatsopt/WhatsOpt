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
        self.xlimits = np.array(xlimits)
        self.workdir = tempfile.TemporaryDirectory()

    def tell(self, x, y):
        self.x = x
        self.y = y

    def ask(self):
        nx = self.x.shape[1]
        ny = self.y.shape[1]
        obj = self.y[:, :1]
        cstrs = self.y[:, 1:]
        print("nx={}, ny={}, y={}".format(nx, ny, obj))

        print("Bounds of design variables:")
        print(self.xlimits)

        lb = self.xlimits[:, 0].tolist()
        ub = self.xlimits[:, 1].tolist()
        print("lower={} upper={}".format(lb, ub))

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
        res = None
        with tempfile.TemporaryDirectory() as tmpdir:
            np.save(os.path.join(tmpdir, "doe"), self.x)
            np.save(os.path.join(tmpdir, "doe_response"), self.y)
            sego = Sego(
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
            res = sego.run_optim(n_iter=1)

        if not res:
            res = (2, np.zeros((1, nx)), np.zeros((1, ny)), 0)
        return res
