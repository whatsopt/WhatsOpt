import unittest
import os
import numpy as np
import subprocess
import time

from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol, TMultiplexedProtocol

from whatsopt_server.services import ttypes as OptimimzerStoreTypes
from whatsopt_server.services import OptimizerStore


class OptimizerStoreProxy(object):
    def __init__(self):
        self.transport = transport = TSocket.TSocket("localhost", 41400)
        transport = TTransport.TBufferedTransport(transport)
        protocol = TBinaryProtocol.TBinaryProtocol(transport)
        protocol = TMultiplexedProtocol.TMultiplexedProtocol(
            protocol, "OptimizerStoreService"
        )
        self._thrift_client = OptimizerStore.Client(protocol)
        transport.open()

    def ping(self):
        return self._thrift_client.ping()

    def create_optimizer(self, optimizer_id, optimizer_kind, options={}):
        self._thrift_client.create_optimizer(optimizer_id, optimizer_kind, options)

    def ask(self, optimizer_id):
        return self._thrift_client.ask(optimizer_id)

    def tell(self, optimizer_id, x, y):
        self._thrift_client.tell(optimizer_id, x, y)

    def destroy_optimizer(self, optimizer_id):
        return self._thrift_client.destroy_optimizer(optimizer_id)

    def close(self):
        self.transport.close()


class TestOptimizerService(unittest.TestCase):
    def setUp(self):
        cmd = os.path.join(
            os.path.dirname(__file__), os.path.pardir, "whatsopt_server", "__main__.py"
        )
        self.server = subprocess.Popen(["python", cmd])
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

    # @unittest.skip("skip")
    def test_create_optimizer(self):
        xlimits = [[-32.768, 32.768], [-32.768, 32.768]]
        self.store.create_optimizer(
            "1",
            OptimizerStore.OptimizerKind.SEGOMOE,
            {"xlimits": OptimizerStore.OptionValue(matrix=xlimits)},
        )

    # @unittest.skip("skip")
    def test_optimizer(self):
        pass


if __name__ == "__main__":
    unittest.main()
