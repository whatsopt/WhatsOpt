import unittest
import os
import numpy as np
from whatsopt.surrogate_store import SurrogateStore

SMT_NOT_INSTALLED = False
try:
    from smt.surrogate_models import KRG
    from smt.extensions import MFK
except:
    SMT_NOT_INSTALLED = True


class TestSurrogateStore(unittest.TestCase):

    def setUp(self):
        self.store = SurrogateStore()

    # @unittest.skip("skip")
    def test_create_surrogate(self):
        xt = np.array([[0.0, 1.0, 2.0, 3.0, 4.0]]).T
        yt = np.array([0.0, 1.0, 1.5, 0.5, 1.0]).T

        self.store.create_surrogate("1", "KRIGING", xt, yt)

    # @unittest.skip("skip")
    def test_get_existing_surrogate(self):
        xt = np.array([[0.0, 1.0, 2.0, 3.0, 4.0]]).T
        yt = np.array([0.0, 1.0, 1.5, 0.5, 1.0]).T

        sm = self.store.create_surrogate("1", "KRIGING", xt, yt)

        num = 13
        x = np.linspace(0.0, 4.0, num)
        y1 = sm.predict_values(x)

        sm2 = self.store.get_surrogate("1")
        y2 = sm2.predict_values(x)

        assert np.array_equal(y1, y2)

    def test_get_non_existing_surrogate(self):

        with self.assertRaises(FileNotFoundError):
            self.store.get_surrogate("2")

    @unittest.skip("skip")
    def test_save_mfk(self):
        def LF_function(x):
            import numpy as np

            return (
                0.5 * ((x * 6 - 2) ** 2) * np.sin((x * 6 - 2) * 2)
                + (x - 0.5) * 10.0
                - 5
            )

        def HF_function(x):
            import numpy as np

            return ((x * 6 - 2) ** 2) * np.sin((x * 6 - 2) * 2)

        # Problem set up
        ndim = 1
        Xt_e = np.linspace(0, 1, 4, endpoint=True).reshape(-1, ndim)
        Xt_c = np.linspace(0, 1, 11, endpoint=True).reshape(-1, ndim)

        nt_exp = Xt_e.shape[0]
        nt_cheap = Xt_c.shape[0]

        # Evaluate the HF and LF functions
        yt_e = HF_function(Xt_e)
        yt_c = LF_function(Xt_c)

        sm = MFK(theta0=np.array(Xt_e.shape[1] * [1.0]))

        # low-fidelity dataset names being integers from 0 to level-1
        sm.set_training_values(Xt_c, yt_c, name=0)
        # high-fidelity dataset without name
        sm.set_training_values(Xt_e, yt_e)

        # train the model
        sm.train()
        # sm.D_all = None
        store = SurrogateStore()
        store.save(sm, 1)
        print(sm.predict_values(np.array([0.314])))


if __name__ == "__main__":
    unittest.main()
