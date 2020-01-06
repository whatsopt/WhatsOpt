import unittest
from whatsopt_services.utils import r2_score


class TestUtils(unittest.TestCase):
    def test_qualify_one(self):
        yv = [1, 2, 3]
        yp = [1, 2, 3]
        self.assertEqual(1.0, r2_score(yv, yp))

    def test_qualify_zero(self):
        yv = [1, 2, 3]
        yp = [2, 2, 2]
        self.assertEqual(0.0, r2_score(yv, yp))

    def test_qualify_neg(self):
        yv = [1, 2, 3]
        yp = [3, 2, 1]
        self.assertEqual(-3.0, r2_score(yv, yp))


if __name__ == "__main__":
    unittest.main()
