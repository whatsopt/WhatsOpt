import unittest
import os
import numpy as np
import subprocess
import time

from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from whatsopt_services.surrogate_server import ttypes as SurrogateStoreTypes

from whatsopt_services.surrogate_server import SurrogateStore


class SurrogateStoreProxy(object):
    def __init__(self):
        self.transport = transport = TSocket.TSocket("localhost", 41400)
        transport = TTransport.TBufferedTransport(transport)
        protocol = TBinaryProtocol.TBinaryProtocol(transport)
        self._thrift_client = SurrogateStore.Client(protocol)
        transport.open()

    def ping(self):
        return self._thrift_client.ping()

    def create_surrogate(self, surrogate_id, surrogate_kind, xt, yt):
        self._thrift_client.create_surrogate(surrogate_id, surrogate_kind, xt, yt)

    def predict_values(self, surrogate_id, xe):
        return self._thrift_client.predict_values(surrogate_id, xe)

    def qualify(self, surrogate_id, xv, yv):
        return self._thrift_client.qualify(surrogate_id, xv, yv)

    def copy_surrogate(self, src_id, dst_id):
        return self._thrift_client.copy_surrogate(src_id, dst_id)

    def destroy_surrogate(self, surrogate_id):
        return self._thrift_client.destroy_surrogate(surrogate_id)

    def get_sobol_pce_sensitivity_analysis(self, surrogate_id):
        return self._thrift_client.get_sobol_pce_sensitivity_analysis(surrogate_id)

    def close(self):
        self.transport.close()


class TestSurrogateServer(unittest.TestCase):
    def setUp(self):
        cmd = os.path.join(
            os.path.dirname(__file__),
            os.path.pardir,
            "whatsopt_services",
            "__main__.py",
        )
        self.server = subprocess.Popen(["python", cmd])
        for _ in range(10):
            try:
                self.store = SurrogateStoreProxy()  # server has to start
            except TTransport.TTransportException:
                time.sleep(0.5)
                continue
            else:
                break

    def tearDown(self):
        self.store.close()
        self.server.kill()

    # @unittest.skip("skip")
    def test_create_surrogate(self):
        xt = np.array([[0.0, 1.0, 2.0, 3.0, 4.0]]).T
        yt = np.array([0.0, 1.0, 1.5, 0.5, 1.0])

        self.store.create_surrogate(
            "1", SurrogateStore.SurrogateKind.SMT_KRIGING, xt, yt
        )

    # @unittest.skip("skip")
    def test_predict(self):

        xt = np.array([[0.0, 1.0, 2.0, 3.0, 4.0]]).T
        yt = np.array([0.0, 1.0, 1.5, 0.5, 1.0])

        self.store.create_surrogate(
            "1", SurrogateStore.SurrogateKind.SMT_KRIGING, xt, yt
        )

        num = 13
        x = np.linspace(0.0, 4.0, num).reshape((1, -1)).T
        y1 = self.store.predict_values("1", x)

        self.assertEqual(13, len(y1))

    def test_sobol_pce(self):
        xt = np.array([[0.0, 1.0, 2.0, 3.0, 4.0]]).T
        yt = np.array([0.0, 1.0, 1.5, 0.5, 1.0])

        self.store.create_surrogate(
            "1", SurrogateStore.SurrogateKind.OPENTURNS_PCE, xt, yt
        )
        sobol = self.store.get_sobol_pce_sensitivity_analysis("1")
        print(sobol)

    def test_qualification(self):
        xt = np.array([[0.0, 1.0, 2.0, 3.0, 4.0]]).T
        yt = np.array([0.0, 1.0, 1.5, 0.5, 1.0])

        self.store.create_surrogate(
            "1", SurrogateStore.SurrogateKind.SMT_KRIGING, xt, yt
        )
        q = self.store.qualify(
            "1", np.array([[0.0, 2.0, 4.0]]).T, np.array([0.0, 1.5, 1.0])
        )
        self.assertAlmostEqual(1.0, q.r2)
        for i, v in enumerate([0.0, 1.5, 1.0]):
            self.assertAlmostEqual(v, q.yp[i])

    def test_copy_predict_destroy(self):
        self.store.copy_surrogate("1", "2")
        num = 13
        x = np.linspace(0.0, 4.0, num).reshape((1, -1)).T
        y1 = self.store.predict_values("2", x)

        self.assertEqual(13, len(y1))
        self.store.destroy_surrogate("2")
        with self.assertRaises(SurrogateStoreTypes.SurrogateException):
            self.store.predict_values("2", x)


if __name__ == "__main__":
    unittest.main()
