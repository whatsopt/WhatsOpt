import unittest
import os
import numpy as np
from whatsopt_server.optimizer_store.segomoe_optimizer import SegomoeOptimizer
import DOE.doe_lhs as doe_lhs
from DOE.tools_doe import trans


class TestSegomoeOptimizer(unittest.TestCase):
    def setUp(self):
        pass

    def tearDown(self):
        pass

    # @unittest.skip("")
    def test_segomoe(self):
        xlimits = np.array([[-32.768, 32.768], [-32.768, 32.768]])
        doe = np.array(
            [
                [0.1005624023, 0.1763338461, 9.09955542],
                [0.843746558, 0.6787895599, 6.38231049],
                [0.3861691997, 0.106018846, 12.4677347],
            ]
        )
        x = doe[:, :2]
        y = doe[:, 2:]

        segomoe = SegomoeOptimizer(xlimits)
        segomoe.tell(x, y)
        res = segomoe.ask()

        # status, x_suggested, y_value, t_elapsed = res
        status, x_suggested, _, _ = res
        self.assertEqual(0, status)
        np.testing.assert_allclose([0.8, 0.7], x_suggested, atol=0.1)

    @staticmethod
    def f(x):
        x1, x2 = x[:, 0], x[:, 1]
        f = np.array((x1 - 10) ** 3 + (x2 - 20) ** 3).reshape((-1, 1))
        return f

    @staticmethod
    def g1(x):
        x1, x2 = x[:, 0], x[:, 1]
        return np.array(100 - (x1 - 5) ** 2 - (x2 - 5) ** 2).reshape((-1, 1))

    @staticmethod
    def g2(x):
        x1, x2 = x[:, 0], x[:, 1]
        return np.array(-82.81 - (x1 - 6) ** 2 - (x2 - 5) ** 2).reshape((-1, 1))

    def test_segomoe_cstrs(self):
        xlimits = np.array([[13, 100], [0, 100]])
        cstrs = [{"type": "<", "bound": 0.0}, {"type": "<", "bound": 0.0}]

        doe = trans(doe_lhs.doe_remi(2, 5), [13, 0], [100, 100])
        print(doe)
        x = doe
        y = np.hstack((self.f(x), self.g1(x), self.g2(x)))

        print(y)

        segomoe = SegomoeOptimizer(xlimits, cstrs)
        segomoe.tell(x, y)
        res = segomoe.ask()

        # status, x_suggested, y_value, t_elapsed = res
        status, x_suggested, _, _ = res
        print(status, x_suggested)


if __name__ == "__main__":
    unittest.main()
