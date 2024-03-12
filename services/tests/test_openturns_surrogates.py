import unittest
import numpy as np
from whatsopt_server.surrogate_store.openturns_surrogates import PCE


def xsinx(x):
    x = np.reshape(x, (-1,))
    y = np.zeros(x.shape)
    y = (x - 3.5) * np.sin((x - 3.5) / (np.pi))
    return y.reshape((-1, 1))


class TestOpenturnsSurrogates(unittest.TestCase):
    def setUp(self):
        self.surr = PCE()
        xt = np.atleast_2d(np.random.uniform(0, 25, 200)).T
        yt = xsinx(xt)
        self.surr.set_training_values(xt, yt)

    def tearDown(self):
        pass

    def test_train_and_predict(self):
        self.surr.train()

        num = 13
        x = np.linspace(0.0, 25.0, num).reshape(-1, 1)
        y = self.surr.predict_values(x)
        self.assertEqual((13, 1), y.shape)
        sa = self.surr.get_sobol_indices()
        self.assertEqual(1.0, sa.getSobolIndex(0))

    def test_train_and_predict_with_uncertainties(self):
        self.surr.set_uncertainties(
            [{"name": "Uniform", "kwargs": {"a": 1.9, "b": 2.3}}]
        )
        self.surr.train()

        num = 100
        x = np.linspace(0.0, 4.0, num).reshape(-1, 1)
        y = self.surr.predict_values(x)

        self.assertEqual((100, 1), y.shape)

        sa = self.surr.get_sobol_indices()
        print(sa.getSobolIndex(0))
        self.assertEqual(1.0, sa.getSobolIndex(0))


if __name__ == "__main__":
    unittest.main()
