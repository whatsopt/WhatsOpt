import os
import numpy as np
import tempfile
import warnings

SEGMOOMOE_NOT_INSTALLED = False
try:
    from moo.smoot import MOO
    from segomoe.constraint import Constraint
    from smt.surrogate_models import KRG, KPLS
    import smt.applications.mixed_integer as mixint

except ImportError:
    warnings.warn("Optimizer SEGOMOE - MOO not installed")
    SEGMOOMOE_NOT_INSTALLED = True

from whatsopt_server.optimizer_store.optimizer import Optimizer
from whatsopt_server.services.ttypes import Type


class SegmoomoeOptimizer(Optimizer):
    def __init__(
        self, xtypes, xlimits, n_obj, cstr_specs=[], mod_obj_options={}, options={}
    ):
        super().__init__(xlimits, n_obj, cstr_specs, mod_obj_options, options)
        self.xtypes = xtypes
        if SEGMOOMOE_NOT_INSTALLED:
            raise RuntimeError("Optimizer SEGMOOMOE not installed")

    def ask(self, with_best=False):
        nx = self.x.shape[1]
        ny = self.y.shape[1]

        # Fake objective function
        def fun(x):
            return (np.max(self.y, axis=0)[: self.n_obj], False)

        cons = [
            Constraint(
                cstr.get("type", "<"),
                cstr.get("bound", 0.0),
                name="c_" + str(i),
                tol=cstr.get("tol", 1e-6),
                f=lambda x: (-np.ones((1, 1)), False),  # Fake constraint function
            )
            for i, cstr in enumerate(self.constraints)
        ]
        # sego store constraint values as positive :
        #  c < bound   => store (bound - c)
        #  c >= bound  => store (c - bound)
        for i, cstr in enumerate(self.constraints):
            idx = self.n_obj + i
            if cstr["type"] == "<":
                self.y[:, idx] = cstr["bound"] - self.y[:, idx]
            else:
                self.y[:, idx] = self.y[:, idx] - cstr["bound"]

        mod_obj = {
            "type": "MIXEDsmt",
            "name": "KRG",
            "eval_noise": False,
            "corr": "squar_exp",
            "xtypes": self.xtypes,
            "xlimits": self.xlimits,
        }
        mod_obj = {**mod_obj, **self.mod_obj_options}
        mod_con = mod_obj
        default_models = {"obj": mod_obj, "con": mod_con}

        optim_settings = {
            "n_start": 10,
            "criterion": "PI",
            "n_iter": 1,
            "pop_size": 30,
            "n_gen": 30,
            "verbose": True,
            "grouped_eval": False,
            "n_clusters": 1,
            "compute_front": with_best,
        }
        optim_settings = {**optim_settings, **self.options}

        res = None
        next_x = None
        with tempfile.TemporaryDirectory() as tmpdir:
            # tmpdir = "/tmp"
            np.save(os.path.join(tmpdir, "doe"), self.x)
            np.save(os.path.join(tmpdir, "doe_response"), self.y)
            segmoomoe = MOO(
                xlimits=self.xlimits,
                xtypes=self.xtypes,
                n_obj=self.n_obj,
                const=cons,
                path_hs=tmpdir,
                model_type=default_models,
                **optim_settings,
            )
            res = segmoomoe.optimize(fun)

        if res:
            if with_best:
                status = segmoomoe.res[0]
                next_x = segmoomoe.sego.get_x()[-1]
                x_best = res.X
                y_best = res.F
            else:
                status = res[0]
                next_x = segmoomoe.sego.get_x()[-1]
                x_best = None
                y_best = None
        else:
            status = 2
            next_x = np.zeros((nx,)).tolist()
            x_best = None
            y_best = None

        print(f"status={status}")
        print(f"next_x={next_x}")
        print(f"x_best={x_best}")
        print(f"y_best={y_best}")

        return status, next_x, x_best, y_best
