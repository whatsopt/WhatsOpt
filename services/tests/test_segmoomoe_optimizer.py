import os
import unittest
import numpy as np
from whatsopt_server.optimizer_store.segmoomoe_optimizer import SegmoomoeOptimizer
from whatsopt_server.services import ttypes as tt
from smt.applications.mixed_integer import FLOAT, INT, MixedIntegerSamplingMethod
from smt.sampling_methods import LHS


def fun(x):  # function with 2 objectives
    f1 = x[:, 0] - x[:, 1] * x[:, 2]
    f2 = 4 * x[:, 0] ** 2 - 4 * x[:, 0] ** x[:, 2] + 1 + x[:, 1]
    f3 = x[:, 0] ** 2
    return (
        np.hstack((np.atleast_2d(f1).T, np.atleast_2d(f2).T, np.atleast_2d(f3).T)),
        False,
    )


def g1(x):  # constraint to force x < 0.8
    return (np.atleast_2d(x[:, 0] - 0.8).T, False)


def g2(x):  # constraint to force x > 0.2
    return (np.atleast_2d(0.2 - x[:, 0]).T, False)


def f_grouped(x):
    resfun = fun(x)[0]
    resg1 = g1(x)[0]
    resg2 = g2(x)[0]
    res = np.hstack((resfun, resg1, resg2))
    return res, False


XDOE = np.array(
    [
        [0.17242353, 1.0, 3.0],
        [0.52616768, 3.0, 2.0],
        [0.42757455, 2.0, 1.0],
        [0.2480228, 0.0, 1.0],
        [0.72319649, 0.0, 1.0],
        [0.66014753, 1.0, 3.0],
        [0.86820021, 2.0, 0.0],
        [0.38944647, 3.0, 0.0],
        [0.04088927, 2.0, 2.0],
        [0.92944837, 1.0, 2.0],
    ]
)
YDOE = np.array(
    [
        [
            -2.82757647e00,
            2.09841498e00,
            2.97298737e-02,
            -6.27576470e-01,
            2.75764701e-02,
        ],
        [
            -5.47383232e00,
            4.00000000e00,
            2.76852424e-01,
            -2.73832323e-01,
            -3.26167677e-01,
        ],
        [
            -1.57242545e00,
            2.02098178e00,
            1.82819995e-01,
            -3.72425451e-01,
            -2.27574549e-01,
        ],
        [
            2.48022796e-01,
            2.53970045e-01,
            6.15153074e-02,
            -5.51977204e-01,
            -4.80227960e-02,
        ],
        [
            7.23196495e-01,
            1.99266701e-01,
            5.23013170e-01,
            -7.68035052e-02,
            -5.23196495e-01,
        ],
        [
            -2.33985247e00,
            2.59242370e00,
            4.35794755e-01,
            -1.39852475e-01,
            -4.60147525e-01,
        ],
        [
            8.68200207e-01,
            2.01508640e00,
            7.53771599e-01,
            6.82002068e-02,
            -6.68200207e-01,
        ],
        [
            3.89446472e-01,
            6.06674217e-01,
            1.51668554e-01,
            -4.10553528e-01,
            -1.89446472e-01,
        ],
        [
            -3.95911073e00,
            3.00000000e00,
            1.67193221e-03,
            -7.59110732e-01,
            1.59110732e-01,
        ],
        [
            -1.07055163e00,
            2.00000000e00,
            8.63874266e-01,
            1.29448367e-01,
            -7.29448367e-01,
        ],
    ]
)


class TestSegmoomoeOptimizer(unittest.TestCase):
    def setUp(self):
        pass

    def tearDown(self):
        pass

    # @unittest.skip("")
    def test_segmoomoe(self):
        ndoe = 10
        xtyps = [FLOAT, INT, INT]
        xlimits = np.array([[0.0, 1.0], [0, 3], [0, 3]])

        # if os.path.exists("out/doe.npy"):
        #     xdoe = np.load("out/doe.npy")
        #     ydoe = np.load("out/doe_response.npy")
        # else:
        #     sampling = MixedIntegerSamplingMethod(xtyps, xlimits, LHS, criterion="ese")
        #     xdoe = sampling(ndoe)
        #     ydoe = f_grouped(xdoe)[0]
        xdoe = XDOE
        ydoe = YDOE

        cstrs = [
            {"type": "<", "bound": 0.0, "tol": 1e-6},
            {"type": "<", "bound": 0.0, "tol": 1e-6},
        ]

        xtypes = []
        xtypes.append(
            tt.Xtype(
                type=tt.Type.FLOAT,
                limits=tt.Xlimits(flimits=tt.Flimits(lower=0.0, upper=1.0)),
            )
        )
        xtypes.append(
            tt.Xtype(
                type=tt.Type.INT,
                limits=tt.Xlimits(ilimits=tt.Ilimits(lower=0, upper=3)),
            )
        )
        xtypes.append(
            tt.Xtype(
                type=tt.Type.INT,
                limits=tt.Xlimits(ilimits=tt.Ilimits(lower=0, upper=3)),
            )
        )

        segmoomoe = SegmoomoeOptimizer(xtypes, 3, cstrs)
        segmoomoe.tell(xdoe, ydoe)
        res = segmoomoe.ask()

        # status, x_suggested, y_value, t_elapsed = res
        status, x_suggested, _ = res
        print(status, x_suggested)


if __name__ == "__main__":
    unittest.main()
