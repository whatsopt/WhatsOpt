from whatsopt_server.services import ttypes as OptimizerStoreTypes
from whatsopt_server.optimizer_store.optimizer_store import OptimizerStore
from smt.utils.design_space import (
    CategoricalVariable,
    OrdinalVariable,
    FloatVariable,
    IntegerVariable,
)

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
    def __init__(self, outdir=".", logdir="."):
        self.optim_store = OptimizerStore(outdir, logdir)

    def ping(self):
        print("Optimizer server... Ping!")

    def shutdown(self):
        exit(0)

    @throw_optimizer_exception
    def create_optimizer(
        self, optimizer_id, optimizer_kind, xlimits, cstr_specs, optimizer_options={}
    ):
        print(
            f"CREATE #{optimizer_id} kind={optimizer_kind} opt={OPTIMIZERS_MAP[optimizer_kind]} " \
            f"xlimits={xlimits} cstr_specs={cstr_specs} options={optimizer_options}"
        )

        cspecs = self._parse_cstrs(cstr_specs)
        mod_obj_options, general_options = self._parse_options(optimizer_options)

        self.optim_store.create_optimizer(
            optimizer_id,
            OPTIMIZERS_MAP[optimizer_kind],
            xlimits,
            cspecs,
            mod_obj_options,
            general_options,
        )

    @throw_optimizer_exception
    def create_mixint_optimizer(
        self, optimizer_id, optimizer_kind, xtyps, n_obj, cstr_specs, optimizer_options={}
    ):
        print(
            f"CREATE #{optimizer_id} kind={optimizer_kind} opt={OPTIMIZERS_MAP[optimizer_kind]} " \
            f"xlimits={xtyps} n_obj={n_obj} cstr_specs={cstr_specs} options={optimizer_options}"
        )

        xspecs = []
        for xtype in xtyps:
            if xtype.type == OptimizerStoreTypes.Type.FLOAT:
                xspecs.append(FloatVariable(xtype.limits.flimits.lower, xtype.limits.flimits.upper))
            elif xtype.type == OptimizerStoreTypes.Type.INT:
                xspecs.append(IntegerVariable(xtype.limits.ilimits.lower, xtype.limits.ilimits.upper))
            elif xtype.type == OptimizerStoreTypes.Type.ORD:
                xspecs.append(OrdinalVariable(xtype.limits.olimits))
            elif xtype.type == OptimizerStoreTypes.Type.ENUM:
                xspecs.append(CategoricalVariable(xtype.limits.elimits))
            else:
                raise ValueError("Unknown xtype {xtype.type}")

        cspecs = self._parse_cstrs(cstr_specs)
        mod_obj_options, general_options = self._parse_options(optimizer_options)

        self.optim_store.create_mixint_optimizer(
            optimizer_id,
            OPTIMIZERS_MAP[optimizer_kind],
            xspecs,
            n_obj,
            cspecs,
            mod_obj_options,
            general_options,
        )


    # @throw_optimizer_exception
    def ask(self, optimizer_id, with_best=False):
        print(f"ASK #{optimizer_id} with_best={with_best}")
        optim = self.optim_store.get_optimizer(optimizer_id)
        if optim:
            status, next_x, x_best, y_best = optim.ask(with_best)
            if with_best:
                print(f"status = {status}, x_suggested = {next_x}, x_best = {x_best}, y_best = {y_best}")
                return OptimizerStoreTypes.OptimizerResult(
                    status=status, x_suggested=next_x, x_best=x_best, y_best=y_best
                )
            else:
                print(f"status = {status}, x_suggested = {next_x}")
                return OptimizerStoreTypes.OptimizerResult(
                    status=status, x_suggested=next_x
                )
        else:
            return OptimizerStoreTypes.OptimizerResult(status=status, x_suggested=[])


    @throw_optimizer_exception
    def tell(self, optimizer_id, x, y):
        print(f"TELL #{optimizer_id} x={x} y={y}")
        self.optim_store.tell_optimizer(optimizer_id, x, y)


    def destroy_optimizer(self, optimizer_id):
        print(f"DESTROY #{optimizer_id}")
        self.optim_store.destroy_optimizer(optimizer_id)


    @staticmethod
    def _parse_cstrs(cstr_specs):
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
        return cspecs

    @staticmethod
    def _parse_options(optimizer_options):
        optimizer_opts = {}
        for k, v in optimizer_options.items():
            if v.boolean is not None:
                optimizer_opts[k] = v.boolean
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

        # filter mod_obj options
        mod_obj_options = {}
        general_options = {}
        for name, val in optimizer_opts.items():
            if name.startswith("mod_obj__"):
                mod_obj_options[name[len("mod_obj__"):]] = val
            else:
                general_options[name] = val
        return mod_obj_options, general_options