import unittest
import os
import numpy as np
from whatsopt_services.surrogate_store import SurrogateStore


class TestSurrogateStore(unittest.TestCase):
    def setUp(self):
        self.store = SurrogateStore()

    def tearDown(self):
        if os.path.exists(self.store._sm_filename("2")):
            os.remove(self.store._sm_filename("2"))

    def test_create_surrogate(self):
        xt = np.array([[0.0, 1.0, 2.0, 3.0, 4.0]]).T
        yt = np.array([0.0, 1.0, 1.5, 0.5, 1.0]).T

        self.store.create_surrogate("1", "SMT_KRIGING", xt, yt)

    def test_get_existing_surrogate(self):
        xt = np.array([[0.0, 1.0, 2.0, 3.0, 4.0]]).T
        yt = np.array([0.0, 1.0, 1.5, 0.5, 1.0]).T

        sm = self.store.create_surrogate("1", "SMT_KRIGING", xt, yt)

        num = 13
        x = np.linspace(0.0, 4.0, num)
        y1 = sm.predict_values(x)

        sm2 = self.store.get_surrogate("1")
        y2 = sm2.predict_values(x)

        self.assertTrue(np.array_equal(y1, y2))

    def test_get_non_existing_surrogate(self):
        with self.assertRaises(FileNotFoundError):
            self.store.get_surrogate("2")

    def test_copy_surrogate(self):
        self.store.copy_surrogate("1", "2")
        self.assertTrue(os.path.exists(self.store._sm_filename("2")))

    def test_create_surrogate_openturns(self):
        xt = np.array([[0.0, 1.0, 2.0, 3.0, 4.0]]).T
        yt = np.array([0.0, 1.0, 1.5, 0.5, 1.0]).T

        sm = self.store.create_surrogate("3", "OPENTURNS_PCE", xt, yt)
        num = 13
        x = np.linspace(0.0, 4.0, num).reshape(-1, 1)
        y = sm.predict_values(x)

        self.assertTrue((13, 1), y.shape)


if __name__ == "__main__":
    unittest.main()
