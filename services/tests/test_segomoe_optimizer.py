import unittest
import os
import numpy as np
from whatsopt_server.optimizer_store.segomoe_optimizer import SegomoeOptimizer


class TestSegomoeOptimizer(unittest.TestCase):
    def setUp(self):
        self.xlimits = np.array([[-32.768, 32.768], [-32.768, 32.768]])
        doe = np.array(
            [
                [0.1005624023, 0.1763338461, 9.09955542],
                [0.843746558, 0.6787895599, 6.38231049],
                [0.3861691997, 0.106018846, 12.4677347],
            ]
        )
        self.x = doe[:, :2]
        self.y = doe[:, 2:]

    def tearDown(self):
        pass

    def test_segomoe(self):
        segomoe = SegomoeOptimizer(self.xlimits)
        segomoe.tell(self.x, self.y)
        res = segomoe.ask()

        # status, x_suggested, y_value, t_elapsed = res
        status, x_suggested, _, _ = res
        self.assertEqual(0, status)
        np.testing.assert_allclose([0.8, 0.7], x_suggested, atol=0.1)


if __name__ == "__main__":
    unittest.main()
