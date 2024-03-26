import os
import numpy as np
import tempfile
import warnings

SEGOMOE_NOT_INSTALLED = False

try:
    from segomoe.sego import Sego
    from segomoe.constraint import Constraint
except ImportError:
    warnings.warn("Optimizer SEGOMOE not installed")
    SEGOMOE_NOT_INSTALLED = True

from whatsopt_server.optimizer_store.optimizer import Optimizer
from smt.utils.design_space import (
    FloatVariable,
)

class SegomoeOptimizer(Optimizer):
    def __init__(self, xlimits, cstr_specs=[], mod_obj_options={}, options={}, logfile=None):
        self.xlimits = np.array(xlimits)

        xspecs = []
        for xlimit in xlimits:
            xspecs.append(FloatVariable(*xlimit))

        super().__init__(xspecs, 1, cstr_specs, mod_obj_options, options, logfile)
        if SEGOMOE_NOT_INSTALLED:
            raise RuntimeError("Optimizer SEGOMOE not installed")

    def ask(self, with_best):
        nx = self.x.shape[1]
        ny = self.y.shape[1]

        print("Bounds of design variables:")
        print(self.xlimits)

        lb = self.xlimits[:, 0].tolist()
        ub = self.xlimits[:, 1].tolist()
        print("lower={} upper={}".format(lb, ub))

        # Fake objective+constraints function
        def f_grouped(x):
            return np.inf * np.ones(ny), False

        dvars = [{"name": "x_" + str(i), "lb": lb[i], "ub": ub[i]} for i in range(nx)]
        print(dvars)
        cons = [
            Constraint(
                cstr.get("type", "<"),
                cstr.get("bound", 0.0),
                name="c_" + str(i),
                tol=cstr.get("tol", 1e-4),
            )
            for i, cstr in enumerate(self.constraints)
        ]
        print(cons)
        # sego store constraint values as positive :
        #   c < bound   => store (bound - c)
        #   c >= bound  => store (c - bound)
        for i, cstr in enumerate(self.constraints):
            if cstr["type"] == "<":
                self.y[:, i + 1] = cstr["bound"] - self.y[:, i + 1]
            else:
                self.y[:, i + 1] = self.y[:, i + 1] - cstr["bound"]

        mod_obj = {
            "name": "KRG",
            "regr": "constant",
            "corr": "squar_exp",
            "theta0": [1.0] * nx,
            "thetaL": [0.1] * nx,
            "thetaU": [10.0] * nx,
            "normalize": True,
            "hyper_opt": "Cobyla",
        }
        mod_obj = {**mod_obj, **self.mod_obj_options}
        mod_con = mod_obj
        default_models = {"obj": mod_obj, "con": mod_con}

        optim_settings = {
            "model_type": default_models,
            "n_clusters": 1,
            "optimizer": "slsqp",
            "analytical_diff": False,
            "grouped_eval": True,
            "profiling": False,
            "verbose": True,
            "cst_crit": "MC",
        }
        optim_settings = {**optim_settings, **self.options}

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
                logfile=self.logfile,
            )
            res = sego.run_optim(n_iter=1)

        x_best = None
        y_best = None
        if res:
            status = res[0]
            next_x = sego.get_x()[-1]
            if with_best:
                x_best = [res[1][0].tolist()]
                y_best = [res[2][0].tolist()]
        else:
            status = 2
            next_x = np.zeros((nx,)).tolist()

        print(f"status={status}")
        print(f"next_x={next_x}")
        print(f"x_best={x_best}")
        print(f"y_best={y_best}")
        print(f"sego.res={res}")

        return status, next_x, x_best, y_best
