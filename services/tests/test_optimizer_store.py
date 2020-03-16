import unittest
import os
import numpy as np
from whatsopt.surrogate_store import OptimizerStore


class TestSurrogateStore(unittest.TestCase):
    def setUp(self):
        self.store = SurrogateStore()

    def tearDown(self):
        if os.path.exists(self.store._sm_filename("1")):
            os.remove(self.store._sm_filename("1"))
        if os.path.exists(self.store._sm_filename("2")):
            os.remove(self.store._sm_filename("2"))
        if os.path.exists(self.store._sm_filename("3")):
            os.remove(self.store._sm_filename("3"))

    def test_create_surrogate(self):
        xt = np.array([[0.0, 1.0, 2.0, 3.0, 4.0]]).T
        yt = np.array([0.0, 1.0, 1.5, 0.5, 1.0]).T

        self.store.create_surrogate("1", "SMT_KRIGING", xt, yt)


if __name__ == "__main__":
    unittest.main()
