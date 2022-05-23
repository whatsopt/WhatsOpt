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

from whatsopt_server.services.ttypes import Type


def func(x):  # function with 2 objectives
    f1 = x[0] - x[1] * x[2]
    f2 = 4 * x[0] ** 2 - 4 * x[0] ** x[2] + 1 + x[1]
    f3 = x[0] ** 2
    return [f1, f2, f3], False


def g1(x):  # constraint to force x < 0.8
    return (x[0] - 0.8, False)


def g2(x):  # constraint to force x > 0.2
    return (0.2 - x[0], False)


class SegmoomoeOptimizer(object):
    def __init__(self, xtypes, xlimits, n_obj, cstr_specs=[]):
        self.constraint_handling = "MC"  # or 'UTB'
        self.xtypes = xtypes
        self.xlimits = np.array(xlimits)
        self.n_obj = n_obj
        self.constraints = cstr_specs
        self.workdir = tempfile.TemporaryDirectory()

    def tell(self, x, y):
        print("X *************************************************")
        print(x)
        print("Y *************************************************")
        print(y)
        nobj = self.n_obj
        ncstrs = len(self.constraints)
        print(y.shape)
        if y.shape[1] != (nobj + ncstrs):
            raise Exception(
                "Size mismatch: y should be {}-size ({} objectives + {} constraints), got {}".format(
                    nobj + ncstrs, nobj, ncstrs, y.shape[1]
                )
            )

        self.x = x
        self.y = y

    def ask(self, with_optima=False):
        nx = self.x.shape[1]
        ny = self.y.shape[1]
        if SEGMOOMOE_NOT_INSTALLED:
            return (
                3,
                np.zeros((1, nx)).flatten().tolist(),
                np.zeros((1, ny)).flatten().tolist(),
                0,
            )
        # obj = self.y[:, :1]
        # cstrs = self.y[:, 1:]
        # nobj = obj.shape[1]
        # ncstrs = cstrs.shape[1]
        # print("nx={}, x={}".format(nx, self.x))
        # print("ny={}, y={}".format(ny, self.y))
        # print("nobj={}, obj={}".format(nobj, obj))
        # print("ncstrs={}, cstrs={}".format(ncstrs, cstrs))

        # Fake objective function
        def fun(x):
            return (-1000 * np.ones(self.n_obj), False)

        CSTR = [g1, g2]
        cons = [
            Constraint(
                cstr.get("type", "<"),
                cstr.get("bound", 0.0),
                name="c_" + str(i),
                tol=cstr.get("tol", 1e-4),
                f=lambda x: (-np.ones((1, 1)), False),  # Fake constraint function
            )
            for i, cstr in enumerate(self.constraints)
        ]
        # sego store constraint values as positive :
        #   c < bound   => store (bound - c)
        #   c >= bound  => store (c - bound)
        for i, cstr in enumerate(self.constraints):
            if cstr["type"] == "<":
                self.y[:, i + 1] = cstr["bound"] - self.y[:, i + 1]
            else:
                self.y[:, i + 1] = self.y[:, i + 1] - cstr["bound"]

        mod_obj = {
            "type": "MIXEDsmt",
            "name": "KRG",
            "eval_noise": False,
            "corr": "squar_exp",
            "xtypes": self.xtypes,
            "xlimits": self.xlimits,
        }
        mod_con = mod_obj
        default_models = {"obj": mod_obj, "con": mod_con}

        res = None

        optim_settings = {
            "n_start": 10,
            "criterion": "PI",
            "random_state": 1,
            "n_iter": 1,
            "pop_size": 30,
            "n_gen": 30,
            "verbose": True,
            "grouped_eval": False,
            "n_clusters": 1,
            "compute_front": with_optima,
        }

        next_x = None
        with tempfile.TemporaryDirectory() as tmpdir:
            # tmpdir = "./out"
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
            res = segmoomoe.optimize(func)

        if res:
            if with_optima:
                status = segmoomoe.res[0]
                next_x = segmoomoe.sego.get_x()[-1]
                best_x = res.X
            else:
                status = res[0]
                next_x = segmoomoe.sego.get_x()[-1]
                best_x = None
        else:
            status = 2
            next_x = np.zeros((nx,)).tolist()
            best_x = np.zeros((nx,)).tolist()

        print(f"status={status}")
        print(f"next_x={next_x}")
        print(f"best_x={best_x}")
        print(f"segmoomoe.res={res}")

        return status, next_x, best_x
