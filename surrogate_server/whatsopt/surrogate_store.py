from os import remove
import numpy as np
try:
    import cPickle as pickle
except:
    import pickle

SMT_NOT_INSTALLED = False
try:
    from smt.surrogate_models import KRG, LS, QP, RBF
    from smt.extensions import MFK
except:
    SMT_NOT_INSTALLED = True

class SurrogateStore(object):
    """
    Object responsible for saving / loading / listing trained surrogates
    """

    def __init__(self, outdir="."):
        self.outdir = outdir

    def create_surrogate(self, surrogate_id, surrogate_kind, xt, yt):
        sm = KRG()
        sm.set_training_values(np.array(xt), np.array(yt))
        sm.train()

        filename = self._sm_filename(surrogate_id)
        with open(filename, "wb") as f:
            pickle.dump(sm, f)

    def get_surrogate(self, surrogate_id):
        filename = self._sm_filename(surrogate_id)
        sm = None
        with open(filename, "rb") as f:
            sm = pickle.load(f)
        return sm

    def destroy_surrogate(self, surrogate_id):
        filename = self._sm_filename(surrogate_id)
        remove(filename)

    def _sm_filename(self, surrogate_id):
        return "%s/surrogate_%s.dat" % (self.outdir, surrogate_id)

