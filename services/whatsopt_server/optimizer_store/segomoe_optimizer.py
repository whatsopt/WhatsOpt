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


class SegomoeOptimizer(object):
    def __init__(self, xlimits, cstr_specs=[]):
        self.constraint_handling = "MC"  # or 'UTB'
        self.xlimits = np.array(xlimits)
        self.constraints = self._parse_constraint_specs(cstr_specs)
        self.workdir = tempfile.TemporaryDirectory()

    @staticmethod
    def _parse_constraint_specs(cstr_specs):
        cstrs = []
        for i, spec in enumerate(cstr_specs):
            if spec["type"] == "<" or spec["type"] == "=" or spec["type"] == ">":
                cstrs.append({"type": spec["type"], "bound": spec["bound"]})
            else:
                print("")
                raise Exception(
                    "Bad constraint spec type (n°{}): should match <, = or > , got {}".format(
                        i + 1, spec
                    )
                )
        return cstrs

    def tell(self, x, y):
        print("X *************************************************")
        print(x)
        print("Y *************************************************")
        print(y)
        ncstrs = len(self.constraints)
        print(y.shape)
        if y.shape[1] != (ncstrs + 1):
            raise Exception(
                "Size mismatch: y should be of {} size (1 objective + {} constraints), got {}".format(
                    ncstrs + 1, ncstrs, y.shape[1]
                )
            )

        self.x = x
        self.y = y

    def ask(self):
        nx = self.x.shape[1]
        ny = self.y.shape[1]
        if SEGOMOE_NOT_INSTALLED:
            return (3, np.zeros((1, nx)), np.zeros((1, ny)), 0)
        # obj = self.y[:, :1]
        # cstrs = self.y[:, 1:]
        # nobj = obj.shape[1]
        # ncstrs = cstrs.shape[1]
        # print("nx={}, x={}".format(nx, self.x))
        # print("ny={}, y={}".format(ny, self.y))
        # print("nobj={}, obj={}".format(nobj, obj))
        # print("ncstrs={}, cstrs={}".format(ncstrs, cstrs))

        print("Bounds of design variables:")
        print(self.xlimits)

        lb = self.xlimits[:, 0].tolist()
        ub = self.xlimits[:, 1].tolist()
        print("lower={} upper={}".format(lb, ub))

        def f_grouped(x):
            return -np.inf * np.ones(ny), False

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
            "type": "Krig",
            "corr": "squared_exponential",
            "theta0": [1.0] * nx,
            "thetaL": [0.1] * nx,
            "thetaU": [10.0] * nx,
            "normalize": True,
        }
        mod_con = mod_obj
        default_models = {"obj": mod_obj, "con": mod_con}
        n_clusters = 1
        optim_settings = {
            "model_type": default_models,
            "n_clusters": n_clusters,
            "optimizer": "slsqp",
            "analytical_diff": False,
            "grouped_eval": True,
            "profiling": False,
            "debug": False,
            "verbose": True,
            "cst_crit": self.constraint_handling,
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

        if res:
            status = res[0]
            next_x = sego.get_x()[-1]
        else:
            status = 2
            next_x = np.zeros((nx,)).tolist()

        print(f"status={status}, next_x={next_x}, segomoe.res={res}")

        return status, next_x
