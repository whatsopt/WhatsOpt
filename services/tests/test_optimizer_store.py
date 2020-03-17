import unittest
import os
import numpy as np
from whatsopt_server.optimizer_store.optimizer_store import OptimizerStore


class TestOptimizerStore(unittest.TestCase):
    def setUp(self):
        self.store = OptimizerStore()

    def tearDown(self):
        if os.path.exists(self.store._optimizer_filename("1")):
            os.remove(self.store._optimizer_filename("1"))

    def test_create_optimizer(self):
        self.store.create_optimizer("1", "SEGOMOE", {})


if __name__ == "__main__":
    unittest.main()
