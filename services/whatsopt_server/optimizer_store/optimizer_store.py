import numpy as np
import os
from shutil import copyfile

try:
    import cPickle as pickle
except:
    import pickle

from whatsopt_server.optimizer_store.segomoe_optimizer import SegomoeOptimizer


class OptimizerStore(object):

    OPTIMIZER_NAMES = ["SEGOMOE"]

    def __init__(self, outdir="."):
        self.outdir = outdir
        self.optimizer_classes = {"SEGOMOE": SegomoeOptimizer}
        if not os.path.exists(outdir):
            os.makedirs(outdir)

    def create_optimizer(
        self, optimizer_id, optimizer_kind, xlimits, cstr_specs=[], optimizer_options={}
    ):
        if optimizer_kind not in OptimizerStore.OPTIMIZER_NAMES:
            raise Exception(
                "Unknown optimizer {} not in {}".format(
                    optimizer_kind, OptimizerStore.OPTIMIZER_NAMES
                )
            )
        print("options = {}".format(optimizer_options))
        self.optimizer = self.optimizer_classes[optimizer_kind](
            xlimits, cstr_specs, **optimizer_options
        )

        self._dump(optimizer_id)
        return self.optimizer

    def tell_optimizer(self, optimizer_id, x, y):
        self.optimizer = self.get_optimizer(optimizer_id)
        self.optimizer.tell(np.array(x), np.array(y))
        self._dump(optimizer_id)

    def get_optimizer(self, optimizer_id):
        filename = self._optimizer_filename(optimizer_id)
        optimizer = None
        with open(filename, "rb") as f:
            optimizer = pickle.load(f)
        return optimizer

    def destroy_optimizer(self, optimizer_id):
        filename = self._optimizer_filename(optimizer_id)
        if os.path.exists(filename):
            os.remove(filename)

    def _optimizer_filename(self, optimizer_id):
        return "%s/optimizer_%s.pkl" % (self.outdir, optimizer_id)

    def _dump(self, optimizer_id):
        filename = self._optimizer_filename(optimizer_id)
        print("DUMP ", filename)
        with open(filename, "wb") as f:
            pickle.dump(self.optimizer, f)
