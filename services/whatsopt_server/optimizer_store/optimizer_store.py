import numpy as np
import os

try:
    import cPickle as pickle
except ImportError:
    import pickle

from whatsopt_server.optimizer_store.segomoe_optimizer import SegomoeOptimizer
from whatsopt_server.optimizer_store.segmoomoe_optimizer import SegmoomoeOptimizer


class OptimizerStore(object):

    SEGOMOE = "SEGOMOE"
    SEGMOOMOE = "SEGMOOMOE"
    OPTIMIZER_NAMES = [SEGOMOE, SEGMOOMOE]

    def __init__(self, outdir="."):
        self.outdir = outdir
        self.optimizer_classes = {
            "SEGOMOE": SegomoeOptimizer,
        }
        self.mixint_optimizer_classes = {
            "SEGMOOMOE": SegmoomoeOptimizer,
        }
        if not os.path.exists(outdir):
            os.makedirs(outdir)

    def create_optimizer(
        self,
        optimizer_id,
        optimizer_kind,
        xlimits,
        cstr_specs=[],
        mod_obj_options={},
        general_options={},
    ):
        print(f"mod obj options = {mod_obj_options}")
        print(f"general options = {general_options}")
        self.optimizer = self.optimizer_classes[optimizer_kind](
            xlimits, cstr_specs, mod_obj_options, general_options
        )
        self._dump(optimizer_id)
        return self.optimizer

    def create_mixint_optimizer(
        self,
        optimizer_id,
        optimizer_kind,
        xtypes,
        xlimits,
        n_obj=1,
        cstr_specs=[],
        mod_obj_options={},
        general_options={},
    ):
        print(f"mod obj options = {mod_obj_options}")
        print(f"general options = {general_options}")
        self.optimizer = self.mixint_optimizer_classes[optimizer_kind](
            xtypes, xlimits, n_obj, cstr_specs, mod_obj_options, general_options
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
