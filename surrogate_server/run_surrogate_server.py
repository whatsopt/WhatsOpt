# -*- coding: utf-8 -*-
#!/usr/bin/env python

import numpy as np

from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift.server import TServer

from whatsopt.surrogate_server import Surrogate as SurrogateService
from smt.surrogate_models import KRG, LS, QP, RBF
from whatsopt.surrogate_store import SurrogateStore

class SurrogateHandler:
    def __init__(self):
        self.sm_store = SurrogateStore()

    def create_surrogate(self, surrogate_id, surrogate_kind, xt, yt):
        self.sm_store.create_surrogate(surrogate_id, surrogate_kind, xt, yt) 

    def predict_values(self, surrogate_id, x):
        sm = self.sm_store.get_surrogate(surrogate_id)
        if sm:
            return sm.predict_values(np.array(x))
        else:
            return []

    def destroy_surrogate(self, surrogate_id):
        self.sm_store.destroy_surrogate(surrogate_id)

handler = SurrogateHandler()
processor = SurrogateService.Processor(handler)
transport = TSocket.TServerSocket('0.0.0.0', port=41400)
tfactory = TTransport.TBufferedTransportFactory()
pfactory = TBinaryProtocol.TBinaryProtocolFactory()

server = TServer.TSimpleServer(processor, transport, tfactory, pfactory)

print("Starting Surrogate server...")
server.serve()
print("done!")
