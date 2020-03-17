import unittest
import os
import numpy as np
from whatsopt_server.optimizer_store.segomoe_optimizer import SegomoeOptimizer


class TestSegomoeOptimizer(unittest.TestCase):
    def setUp(self):
        self.cfg_input = {
            "Bound_DV": [["-32.768", "32.768"], ["-32.768", "32.768"]],
            "ObjFun": ["obj1"],
            "Constraints": [],
        }
        self.DOE_input = [
            [
                [0.1005624023, 0.843746558, 0.3861691997],
                [0.1763338461, 0.6787895599, 0.106018846],
            ],
            [[9.09955542, 6.38231049, 12.4677347]],
        ]

    def tearDown(self):
        pass

    def test_segomoe(self):
        segomoe = SegomoeOptimizer(self.cfg_input, self.DOE_input)

        segomoe.ask()


if __name__ == "__main__":
    unittest.main()
