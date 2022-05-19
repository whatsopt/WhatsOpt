import unittest
import os
import numpy as np
from whatsopt_server.optimizer_store.optimizer_store import OptimizerStore
from whatsopt_server.optimizer_store.segomoe_optimizer import SegomoeOptimizer
import DOE.doe_lhs as doe_lhs
from DOE.tools_doe import trans


class TestOptimizerStore(unittest.TestCase):
    def setUp(self):
        self.store = OptimizerStore()

    def tearDown(self):
        if os.path.exists(self.store._optimizer_filename("1")):
            os.remove(self.store._optimizer_filename("1"))

    # @unittest.skip("")
    def test_create_optimizer(self):
        self.xlimits = np.array([[-32.768, 32.768], [-32.768, 32.768]])
        self.store.create_optimizer("1", "SEGOMOE", self.xlimits, [])

        opt = self.store.get_optimizer("1")
        self.assertTrue(isinstance(opt, SegomoeOptimizer))

    # @unittest.skip("")
    def test_optimizer(self):
        doe = np.array(
            [
                [0.1005624023, 0.1763338461, 9.09955542],
                [0.843746558, 0.6787895599, 6.38231049],
                [0.3861691997, 0.106018846, 12.4677347],
            ]
        )
        self.x = doe[:, 0:2]
        self.y = doe[:, 2:3]
        self.xlimits = np.array([[-32.768, 32.768], [-32.768, 32.768]])
        self.store.create_optimizer("1", "SEGOMOE", self.xlimits, [])
        self.store.tell_optimizer("1", self.x, self.y)
        opt = self.store.get_optimizer("1")
        status, _, _ = opt.ask()

        self.store.tell_optimizer("1", self.x, self.y)
        opt1 = self.store.get_optimizer("1")
        status1, _, _ = opt1.ask()
        self.assertEqual(status, status1)

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

        self.store.create_optimizer("1", "SEGOMOE", xlimits, cstrs)
        self.store.tell_optimizer("1", x, y)
        opt = self.store.get_optimizer("1")
        status, next_x, best_x = opt.ask()
        print(status, next_x)

    def test_bad_constraints_specs(self):
        xlimits = np.array([[13, 100], [0, 100]])
        cstrs = [{"type": "?", "bound": 0.0}, {"type": "<", "bound": 0.0}]
        with self.assertRaises(Exception):
            self.store.create_optimizer("1", "SEGOMOE", xlimits, cstrs)

    def test_bad_response_size(self):
        xlimits = np.array([[13, 100], [0, 100]])
        cstrs = [{"type": "<", "bound": 0.0}, {"type": "<", "bound": 0.0}]
        doe = trans(doe_lhs.doe_remi(2, 5), [13, 0], [100, 100])
        print(doe)
        x = doe
        y = np.hstack((self.f(x), self.g1(x)))

        self.store.create_optimizer("1", "SEGOMOE", xlimits, cstrs)
        with self.assertRaises(Exception):
            self.store.tell_optimizer("1", x, y)


if __name__ == "__main__":
    unittest.main()
