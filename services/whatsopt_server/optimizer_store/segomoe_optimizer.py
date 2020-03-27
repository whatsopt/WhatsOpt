import os
import sys
import numpy as np
import re
import csv
import tempfile
import warnings

SEGOMOE_NOT_INSTALLED = False
try:
    from segomoe.sego import Sego
    from segomoe.constraint import Constraint
except ImportError:
    warnings.warn("Optimizer SEGOMOE not installed")
    SEGOMOE_NOT_INSTALLED = True


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
        if SEGOMOE_NOT_INSTALLED:
            return (3, np.zeros((1, nx)), np.zeros((1, ny)), 0)
        obj = self.y[:, :1]
        nobj = obj.shape[1]
        cstrs = self.y[:, 1:]
        ncstrs = cstrs.shape[1]

        print("nx={}, x={}".format(nx, self.x))
        print("ny={}, y={}".format(ny, self.y))
        print("nobj={}, obj={}".format(nobj, obj))
        print("ncstrs={}, cstrs={}".format(ncstrs, cstrs))

        print("Bounds of design variables:")
        print(self.xlimits)

        lb = self.xlimits[:, 0].tolist()
        ub = self.xlimits[:, 1].tolist()
        print("lower={} upper={}".format(lb, ub))

        def f_grouped(x):
            return -sys.float_info.max * np.ones(ny), False

        def g(x):
            return 1

        dvars = [{"name": "x_" + str(i), "lb": lb[i], "ub": ub[i]} for i in range(nx)]
        print(dvars)
        cons = [
            Constraint("<", 0.0, name="c_" + str(i), f=g, tol=1e-4)
            for i in range(ncstrs)
        ]
        print(cons)

        mod_obj = {
            "type": "Krig",
            "corr": "squared_exponential",
            "theta0": [1.0] * nx,
            "thetaL": [0.1] * nx,
            "thetaU": [10.0] * nx,
        }
        mod_con = mod_obj
        default_models = {"obj": mod_obj, "con": mod_con}
        n_clusters = 1
        optim_settings = {
            "model_type": default_models,
            "n_clusters": n_clusters,
            "grouped_eval": True,
            "analytical_diff": True,
            "profiling": False,
            "debug": False,
            "verbose": True,
            "cst_hand": self.constraint_handling,
        }

        res = None
        with tempfile.TemporaryDirectory() as tmpdir:
            np.save(os.path.join(tmpdir, "doe"), self.x)
            np.save(os.path.join(tmpdir, "doe_response"), self.y)
            sego = Sego(
                fun=f_grouped,
                var=dvars,
                const=cons,
                optim_settings=optim_settings,
                path_hs=tmpdir,
                comm=None,
            )
            res = sego.run_optim(n_iter=1)
            print(res)
        if not res:
            res = (2, np.zeros((1, nx)), np.zeros((1, ny)), 0)
        return res
