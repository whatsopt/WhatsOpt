import pickle
from smt.utils.printer import Printer
from smt.utils.options_dictionary import OptionsDictionary


class SurrogateStore(object):
    """
    Object responsible for saving / loading / listing trained surrogates
    """

    def __init__(self, outdir="."):
        self.outdir = outdir

    def save(self, surr, id):
        with open("test", "wb") as f:
            pickle.dump(surr, f)

    def load(self, id):
        with open("test", "rb") as f:
            surr = pickle.load(f)
            return surr

