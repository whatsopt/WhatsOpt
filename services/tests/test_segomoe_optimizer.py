import unittest
import numpy as np
from whatsopt_server.optimizer_store.segomoe_optimizer import SegomoeOptimizer
from smt.sampling_methods import LHS

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
        res = segomoe.ask(with_best=True)

        # status, x_suggested, y_value, t_elapsed = res
        status, x_suggested, x_best, y_best = res
        self.assertEqual(0, status)
        self.assertNotEqual(None, x_best)
        self.assertNotEqual(None, y_best)
        print(status, x_suggested)

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

        lhs = LHS(xlimits=xlimits)
        doe = lhs(5)
        print(doe)
        x = doe
        y = np.hstack((self.f(x), self.g1(x), self.g2(x)))

        print(y)

        segomoe = SegomoeOptimizer(xlimits, cstrs)
        segomoe.tell(x, y)
        res = segomoe.ask(with_best=False)

        # status, x_suggested, y_value, t_elapsed = res
        status, x_suggested, x_best, y_best = res
        self.assertEqual(None, x_best)
        self.assertEqual(None, y_best)
        print(status, x_suggested)


if __name__ == "__main__":
    unittest.main()
