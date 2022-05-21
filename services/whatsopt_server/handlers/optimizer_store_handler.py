from whatsopt_server.services import ttypes as OptimizerStoreTypes
from whatsopt_server.optimizer_store.optimizer_store import OptimizerStore
import smt.applications.mixed_integer as mixint

OPTIMIZERS_MAP = {
    OptimizerStoreTypes.OptimizerKind.SEGOMOE: OptimizerStore.SEGOMOE,
    OptimizerStoreTypes.OptimizerKind.SEGMOOMOE: OptimizerStore.SEGMOOMOE
}


def throw_optimizer_exception(func):
    def func_wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except Exception as err:
            exc = OptimizerStoreTypes.OptimizerException()
            exc.msg = str(err)
            raise exc

    return func_wrapper


class OptimizerStoreHandler:
    def __init__(self, outdir="."):
        self.optim_store = OptimizerStore(outdir)

    def ping(self):
        print("Optimizer server... Ping!")

    def shutdown(self):
        exit(0)

    @throw_optimizer_exception
    def create_optimizer(
        self, optimizer_id, optimizer_kind, xlimits, cstr_specs, optimizer_options={}
    ):
        print(
            "CREATE ",
            optimizer_id,
            optimizer_kind,
            OPTIMIZERS_MAP[optimizer_kind],
            xlimits,
            cstr_specs,
            optimizer_options,
        )
        cspecs = []
        for cspec in cstr_specs:
            print(cspec)
            if cspec.type == OptimizerStoreTypes.ConstraintType.GREATER:
                cspecs.append({"type": ">", "bound": cspec.bound})
            elif cspec.type == OptimizerStoreTypes.ConstraintType.EQUAL:
                cspecs.append({"type": "=", "bound": cspec.bound})
            elif cspec.type == OptimizerStoreTypes.ConstraintType.LESS:
                cspecs.append({"type": "<", "bound": cspec.bound})
            else:
                Exception(
                    "Bad constraint specification: should be <, > or =, got {}".format(
                        cspec.type
                    )
                )
        optimizer_opts = {}
        for k, v in optimizer_options.items():
            if v.integer is not None:
                optimizer_opts[k] = v.integer
            if v.number is not None:
                optimizer_opts[k] = v.number
            if v.vector is not None:
                optimizer_opts[k] = v.vector
            if v.matrix is not None:
                optimizer_opts[k] = v.matrix
            if v.str is not None:
                optimizer_opts[k] = v.str

        self.optim_store.create_optimizer(
            optimizer_id,
            OPTIMIZERS_MAP[optimizer_kind],
            xlimits,
            cspecs,
            optimizer_opts,
        )

    @throw_optimizer_exception
    def create_mixint_optimizer(
        self, optimizer_id, optimizer_kind, xtyps, n_obj, cstr_specs, optimizer_options={}
    ):
        print(
            "CREATE MIXINT OPTIM",
            optimizer_id,
            optimizer_kind,
            OPTIMIZERS_MAP[optimizer_kind],
            xtyps,
            n_obj,
            cstr_specs,
            optimizer_options,
        )

        xtypes = []
        xlimits = []
        for xtype in xtyps:
            if xtype.type == OptimizerStoreTypes.Type.FLOAT:
                xtypes.append(mixint.FLOAT)
                xlimits.append([xtype.limits.flimits.lower, xtype.limits.flimits.upper])
            elif xtype.type == OptimizerStoreTypes.Type.INT:
                xtypes.append(mixint.INT)
                xlimits.append([xtype.limits.ilimits.lower, xtype.limits.ilimits.upper])
            elif xtype.type == OptimizerStoreTypes.Type.ORD:
                xtypes.append(mixint.ORD)
                xlimits.append(xtype.limits.olimits)
            elif xtype.type == OptimizerStoreTypes.Type.ENUM:
                xtypes.append((mixint.ENUM, len(xtype.limits.elimits)))
                xlimits.append(xtype.limits.elimits)
            else:
                raise ValueError("Unknown xtype {xtype.type}")

        cspecs = []
        for cspec in cstr_specs:
            print(cspec)
            if cspec.type == OptimizerStoreTypes.ConstraintType.GREATER:
                cspecs.append({"type": ">", "bound": cspec.bound})
            elif cspec.type == OptimizerStoreTypes.ConstraintType.EQUAL:
                cspecs.append({"type": "=", "bound": cspec.bound})
            elif cspec.type == OptimizerStoreTypes.ConstraintType.LESS:
                cspecs.append({"type": "<", "bound": cspec.bound})
            else:
                raise ValueError(
                    "Bad constraint specification: should be <, > or =, got {}".format(
                        cspec.type
                    )
                )
        optimizer_opts = {}
        for k, v in optimizer_options.items():
            if v.integer is not None:
                optimizer_opts[k] = v.integer
            if v.number is not None:
                optimizer_opts[k] = v.number
            if v.vector is not None:
                optimizer_opts[k] = v.vector
            if v.matrix is not None:
                optimizer_opts[k] = v.matrix
            if v.str is not None:
                optimizer_opts[k] = v.str

        self.optim_store.create_mixint_optimizer(
            optimizer_id,
            OPTIMIZERS_MAP[optimizer_kind],
            xtypes,
            xlimits,
            n_obj,
            cspecs,
            optimizer_opts,
        )


    @throw_optimizer_exception
    def ask(self, optimizer_id):
        print("ASK", optimizer_id)
        optim = self.optim_store.get_optimizer(optimizer_id)
        if optim:
            status, next_x, _ = optim.ask()
            print(f"status = {status}, x_suggested = {next_x}")
            return OptimizerStoreTypes.OptimizerResult(
                status=status, x_suggested=next_x
            )
        else:
            return OptimizerStoreTypes.OptimizerResult(status=status, x_suggested=[])

    @throw_optimizer_exception
    def tell(self, optimizer_id, x, y):
        print("TELL", optimizer_id, x, y)
        self.optim_store.tell_optimizer(optimizer_id, x, y)

    def destroy_optimizer(self, optimizer_id):
        print("DESTROY")
        self.optim_store.destroy_optimizer(optimizer_id)
