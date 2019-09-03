import unittest
import os
import numpy as np
from whatsopt.surrogate_store import SurrogateStore as SurrogateStoreImpl
from whatsopt.surrogate_server import SurrogateStore

SMT_NOT_INSTALLED = False
try:
    from smt.surrogate_models import KRG
    from smt.extensions import MFK
except:
    SMT_NOT_INSTALLED = True

from thrift import Thrift
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol


class SurrogateStoreProxy(object):
    def __init__(self):
        self.transport = transport = TSocket.TSocket("localhost", 41400)
        transport = TTransport.TBufferedTransport(transport)
        protocol = TBinaryProtocol.TBinaryProtocol(transport)
        self._thrift_client = SurrogateStore.Client(protocol)
        transport.open()

    def create_surrogate(self, surrogate_id, surrogate_kind, xt, yt):
        self._thrift_client.create_surrogate(surrogate_id, surrogate_kind, xt, yt)

    def predict_values(self, surrogate_id, xe):
        return self._thrift_client.predict_values(surrogate_id, xe)

    def qualify(self, surrogate_id, xv, yv):
        return self._thrift_client.qualify(surrogate_id, xv, yv)

    def close(self):
        self.transport.close()


class TestSurrogateServer(unittest.TestCase):
    def setUp(self):
        self.store = SurrogateStoreProxy()

    def tearDown(self):
        self.store.close()

    # @unittest.skip("skip")
    def test_create_surrogate(self):
        xt = np.array([[0.0, 1.0, 2.0, 3.0, 4.0]]).T
        yt = np.array([0.0, 1.0, 1.5, 0.5, 1.0])

        self.store.create_surrogate("1", SurrogateStore.SurrogateKind.KRIGING, xt, yt)

    # @unittest.skip("skip")
    def test_predict(self):

        xt = np.array([[0.0, 1.0, 2.0, 3.0, 4.0]]).T
        yt = np.array([0.0, 1.0, 1.5, 0.5, 1.0])

        self.store.create_surrogate("1", SurrogateStore.SurrogateKind.KRIGING, xt, yt)

        num = 13
        x = np.linspace(0.0, 4.0, num).reshape((1, -1)).T
        y1 = self.store.predict_values("1", x)

        self.assertEqual(13, len(y1))
        self.store.close()

    def test_qualification(self):
        xt = np.array([[0.0, 1.0, 2.0, 3.0, 4.0]]).T
        yt = np.array([0.0, 1.0, 1.5, 0.5, 1.0])

        self.store.create_surrogate("1", SurrogateStore.SurrogateKind.KRIGING, xt, yt)
        q = self.store.qualify("1", np.array([[0.0, 2.0, 4.0]]).T, np.array([0.0, 1.5, 1.0]))
        self.assertAlmostEqual(1.0, q.r2)
        for i, v in enumerate([0.0, 1.5, 1.0]):
            self.assertAlmostEqual(v, q.yp[i])


if __name__ == "__main__":
    unittest.main()
