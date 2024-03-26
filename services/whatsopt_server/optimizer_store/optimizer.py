import tempfile
from smt.utils.design_space import (
    DesignSpace,
)


class Optimizer:
    def __init__(self, xspecs, n_obj, cstr_specs, mod_obj_options, options, logfile):
        self.design_space = DesignSpace(xspecs)
        self.n_obj = n_obj
        self.constraints = self._check_constraint_specs(cstr_specs)
        self.mod_obj_options = mod_obj_options
        self.options = options
        self.logfile = logfile
        self.workdir = tempfile.TemporaryDirectory()

    @staticmethod
    def _check_constraint_specs(cstr_specs):
        cstrs = []
        for i, spec in enumerate(cstr_specs):
            if spec["type"] == "<" or spec["type"] == "=" or spec["type"] == ">":
                cstrs.append({"type": spec["type"], "bound": spec["bound"]})
            else:
                raise ValueError(
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
        nobj = self.n_obj
        ncstrs = len(self.constraints)
        print(f"Y shape = {y.shape}")
        print(f"n_obj={nobj}")
        print(f"n_cstrs={ncstrs}")
        if y.shape[1] != (nobj + ncstrs):
            raise ValueError(
                "Size mismatch: y should be {}-size ({} objectives + {} constraints), got {}".format(
                    nobj + ncstrs, nobj, ncstrs, y.shape[1]
                )
            )

        self.x = x
        self.y = y

    def ask(self, with_best=False):
        raise RuntimeError("Not yet implemented")
