import unittest
import os
import numpy as np
from whatsopt_server.optimizer_store.optimizer_store import OptimizerStore
from whatsopt_server.optimizer_store.segomoe_optimizer import SegomoeOptimizer


class TestOptimizerStore(unittest.TestCase):
    def setUp(self):
        self.store = OptimizerStore()
        doe = np.array(
            [
                [0.1005624023, 0.1763338461, 9.09955542],
                [0.843746558, 0.6787895599, 6.38231049],
                [0.3861691997, 0.106018846, 12.4677347],
            ]
        )
        self.x = doe[:, 0:2]
        self.y = doe[:, 2:3]

    def tearDown(self):
        if os.path.exists(self.store._optimizer_filename("1")):
            os.remove(self.store._optimizer_filename("1"))

    def test_create_optimizer(self):
        self.xlimits = np.array([[-32.768, 32.768], [-32.768, 32.768]])
        self.store.create_optimizer("1", "SEGOMOE", {"xlimits": self.xlimits})

        opt = self.store.get_optimizer("1")
        self.assertTrue(isinstance(opt, SegomoeOptimizer))

    def test_optimizer(self):
        self.xlimits = np.array([[-32.768, 32.768], [-32.768, 32.768]])
        self.store.create_optimizer("1", "SEGOMOE", {"xlimits": self.xlimits})
        self.store.tell_optimizer("1", self.x, self.y)
        opt = self.store.get_optimizer("1")
        status, next_x, _, _ = opt.ask()

        self.store.tell_optimizer("1", self.x, self.y)
        opt1 = self.store.get_optimizer("1")
        status1, next_x1, _, _ = opt1.ask()
        self.assertEqual(status, status1)
        np.testing.assert_allclose(next_x1, next_x, atol=0.1)


if __name__ == "__main__":
    unittest.main()
