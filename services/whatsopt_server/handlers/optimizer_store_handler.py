import numpy as np

from whatsopt_server.services import ttypes as OptimizerStoreTypes
from whatsopt_server.optimizer_store.optimizer_store import OptimizerStore

OPTIMIZERS_MAP = {
    OptimizerStoreTypes.OptimizerKind.SEGOMOE: OptimizerStore.OPTIMIZER_NAMES[0]
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
    def create_optimizer(self, optimizer_id, optimizer_kind, optimizer_options={}):
        print(
            "CREATE ",
            optimizer_id,
            optimizer_kind,
            OPTIMIZERS_MAP[optimizer_kind],
            optimizer_options,
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
            optimizer_id, OPTIMIZERS_MAP[optimizer_kind], optimizer_opts
        )

    @throw_optimizer_exception
    def ask(self, optimizer_id):
        print("ASK", optimizer_id)
        optim = self.optim_store.get_optimizer(optimizer_id)
        if optim:
            print("GOING TO ASK...")
            status, x, _, _ = optim.ask()
            print("status = {}, x_suggested = {}".format(status, x))
            return OptimizerStoreTypes.OptimizerResult(status=status, x_suggested=x)
        else:
            return OptimizerStoreTypes.OptimizerResult(status=status, x_suggested=[])

    @throw_optimizer_exception
    def tell(self, optimizer_id, x, y):
        print("TELL", optimizer_id, x, y)
        self.optim_store.tell_optimizer(optimizer_id, x, y)

    def destroy_optimizer(self, optimizer_id):
        print("DESTROY")
        self.optim_store.destroy_optimizer(optimizer_id)
