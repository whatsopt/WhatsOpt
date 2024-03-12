import unittest
import os
import numpy as np
import subprocess
import time

from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol, TMultiplexedProtocol

from whatsopt_server.services import OptimizerStore, Administration
import whatsopt_server.services.ttypes as tt
from smt.sampling_methods import LHS


class OptimizerStoreProxy(object):
    def __init__(self):
        self.transport = transport = TSocket.TSocket("localhost", 41400)
        transport = TTransport.TBufferedTransport(transport)
        protocol = TBinaryProtocol.TBinaryProtocol(transport)
        multiplex1 = TMultiplexedProtocol.TMultiplexedProtocol(
            protocol, "OptimizerStoreService"
        )
        self._thrift_client = OptimizerStore.Client(multiplex1)
        multiplex2 = TMultiplexedProtocol.TMultiplexedProtocol(
            protocol, "AdministrationService"
        )
        self._admin_client = Administration.Client(multiplex2)
        transport.open()

    def ping(self):
        return self._thrift_client.ping()

    def create_optimizer(
        self, optimizer_id, optimizer_kind, xlimits, cstr_spec, options={}
    ):
        self._thrift_client.create_optimizer(
            optimizer_id, optimizer_kind, xlimits, cstr_spec, options
        )

    def create_mixint_optimizer(
        self, optimizer_id, optimizer_kind, xtypes, n_obj, cstr_spec, options={}
    ):
        self._thrift_client.create_mixint_optimizer(
            optimizer_id, optimizer_kind, xtypes, n_obj, cstr_spec, options
        )

    def ask(self, optimizer_id, with_best):
        return self._thrift_client.ask(optimizer_id, with_best)

    def tell(self, optimizer_id, x, y):
        self._thrift_client.tell(optimizer_id, x, y)

    def destroy_optimizer(self, optimizer_id):
        return self._thrift_client.destroy_optimizer(optimizer_id)

    def close(self):
        self.transport.close()


# Test function for SEGOMOOMOE
def fun(x):  # function with 2 objectives
    x = np.atleast_2d(x)
    f1 = x[:, 0] - x[:, 1] * x[:, 2]
    f2 = 4 * x[:, 0] ** 2 - 4 * x[:, 0] ** x[:, 2] + 1 + x[:, 1]
    f3 = x[:, 0] ** 2
    return np.hstack((np.atleast_2d(f1).T, np.atleast_2d(f2).T, np.atleast_2d(f3).T))


def g1(x):  # constraint to force x < 0.8
    x = np.atleast_2d(x)
    return np.atleast_2d(x[:, 0] - 0.8).T


def g2(x):  # constraint to force x > 0.2
    x = np.atleast_2d(x)
    return np.atleast_2d(0.2 - x[:, 0]).T


def f_grouped(x):
    resfun = fun(x)
    resg1 = g1(x)
    resg2 = g2(x)
    res = np.hstack((resfun, resg1, resg2))
    return res


class TestOptimizerService(unittest.TestCase):
    def setUp(self):
        cmd = os.path.join(
            os.path.dirname(__file__), os.path.pardir, "whatsopt_server", "__main__.py"
        )
        self.server = subprocess.Popen(
            ["python", cmd, "--logdir", ".", "--outdir", "."]
        )
        for _ in range(10):
            try:
                self.store = OptimizerStoreProxy()  # server has to start
            except TTransport.TTransportException:
                time.sleep(0.5)
                continue
            else:
                break

    def tearDown(self):
        self.store.close()
        self.server.kill()
        time.sleep(0.5)

    # @unittest.skip("skip")
    def test_create_optimizer(self):
        xlimits = [[-32.768, 32.768], [-32.768, 32.768]]
        self.store.create_optimizer(
            "1", OptimizerStore.OptimizerKind.SEGOMOE, xlimits, []
        )
        self.store.destroy_optimizer("1")

    # @unittest.skip("skip")
    def test_optimizer(self):
        xlimits = [[-32.768, 32.768], [-32.768, 32.768]]
        self.store.create_optimizer(
            "1", OptimizerStore.OptimizerKind.SEGOMOE, xlimits, []
        )
        # test
        doe = np.array(
            [
                [0.1005624023, 0.1763338461, 9.09955542],
                [0.843746558, 0.6787895599, 6.38231049],
                [0.3861691997, 0.106018846, 12.4677347],
            ]
        )
        x = doe[:, :2]
        y = doe[:, 2:]

        self.store.tell("1", x, y)
        res = self.store.ask("1", True)

        self.assertEqual(0, res.status)

        self.store.destroy_optimizer("1")

    # @unittest.skip("skip")
    def test_optimizer_cstr(self):
        xlimits = [[-32.768, 32.768], [-32.768, 32.768]]
        self.store.create_optimizer(
            "1", OptimizerStore.OptimizerKind.SEGOMOE, xlimits, []
        )
        # test
        doe = np.array(
            [
                [0.1005624023, 0.1763338461, 9.09955542],
                [0.843746558, 0.6787895599, 6.38231049],
                [0.3861691997, 0.106018846, 12.4677347],
            ]
        )
        x = doe[:, :2]
        y = doe[:, 2:]

        self.store.tell("1", x, y)
        res = self.store.ask("1", False)

        self.assertEqual(0, res.status)

        self.store.destroy_optimizer("1")

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

    # @unittest.skip("skip")
    def test_segomoe_cstrs(self):

        xlimits = np.array([[13, 100], [0, 100]])

        lhs = LHS(xlimits=xlimits)
        doe = lhs(5)
        print(doe)
        x = doe
        y = np.hstack((self.f(x), self.g1(x), self.g2(x)))

        self.store.create_optimizer(
            "1",
            OptimizerStore.OptimizerKind.SEGOMOE,
            xlimits,
            [
                OptimizerStore.ConstraintSpec(
                    type=OptimizerStore.ConstraintType.LESS, bound=0.0
                ),
                OptimizerStore.ConstraintSpec(
                    type=OptimizerStore.ConstraintType.LESS, bound=0.0
                ),
            ],
        )
        self.store.tell("1", x, y)
        res = self.store.ask("1", True)
        print(res.status, res.x_suggested)

    # @unittest.skip("")
    def test_segmoomoe_cstrs(self):
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

        xdoe = np.array(
            [
                [0.36691555, 0.0, 1.0],
                [0.58432706, 1.0, 1.0],
                [0.09227899, 1.0, 2.0],
                [0.95274182, 1.0, 2.0],
                [0.72873502, 1.0, 3.0],
                [0.87115983, 2.0, 1.0],
                [0.24346361, 2.0, 3.0],
                [0.4221473, 2.0, 0.0],
                [0.10886813, 2.0, 1.0],
                [0.65557784, 3.0, 2.0],
                [0.39532629, 2.0, 0.0],
            ]
        )
        ydoe = f_grouped(xdoe)
        print(ydoe)
        self.store.create_mixint_optimizer(
            "2",
            OptimizerStore.OptimizerKind.SEGMOOMOE,
            xtypes,
            3,
            [
                OptimizerStore.ConstraintSpec(
                    type=OptimizerStore.ConstraintType.LESS, bound=0.0
                ),
                OptimizerStore.ConstraintSpec(
                    type=OptimizerStore.ConstraintType.LESS, bound=0.0
                ),
            ],
        )
        self.store.tell("2", xdoe, ydoe)
        res = self.store.ask("2", True)
        print(res.status, res.x_suggested)


if __name__ == "__main__":
    unittest.main()
