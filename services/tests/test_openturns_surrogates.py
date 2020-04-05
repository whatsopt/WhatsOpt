import unittest
import numpy as np
from whatsopt_server.surrogate_store.openturns_surrogates import PCE


class TestOpenturnsSurrogates(unittest.TestCase):
    def setUp(self):
        xt = np.array([[0.0, 1.0, 2.0, 3.0, 4.0]]).T
        yt = np.array([0.0, 1.0, 1.5, 0.5, 1.0]).T
        self.surr = PCE()
        self.surr.set_training_values(xt, yt)

    def tearDown(self):
        pass

    def test_train_and_predict(self):
        self.surr.train()

        num = 13
        x = np.linspace(0.0, 4.0, num).reshape(-1, 1)
        y = self.surr.predict_values(x)

        self.assertEqual((13, 1), y.shape)

        sa = self.surr.get_sobol_indices()
        self.assertEqual(1.0, sa.getSobolIndex(0))

    def test_train_and_predict_with_uncertainties(self):
        self.surr.set_uncertainties(
            [{"name": "Uniform", "kwargs": {"a": 1.9, "b": 2.3}}]
        )
        self.surr.train()

        num = 13
        x = np.linspace(0.0, 4.0, num).reshape(-1, 1)
        y = self.surr.predict_values(x)

        self.assertEqual((13, 1), y.shape)

        sa = self.surr.get_sobol_indices()
        print(sa.getSobolIndex(0))
        self.assertEqual(1.0, sa.getSobolIndex(0))


if __name__ == "__main__":
    unittest.main()
