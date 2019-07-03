# -*- coding: utf-8 -*-
#!/usr/bin/env python

import numpy as np

from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift.server import TServer

from whatsopt.surrogate_server import ttypes as SurrogateStoreTypes
from whatsopt.surrogate_server import SurrogateStore as SurrogateStoreService
from whatsopt.surrogate_store import SurrogateStore

SURROGATES_MAP = {
    SurrogateStoreTypes.SurrogateKind.KRIGING: SurrogateStore.SURROGATE_NAMES[0],
    SurrogateStoreTypes.SurrogateKind.KPLS: SurrogateStore.SURROGATE_NAMES[1],
    SurrogateStoreTypes.SurrogateKind.KPLSK: SurrogateStore.SURROGATE_NAMES[2],
    SurrogateStoreTypes.SurrogateKind.LS: SurrogateStore.SURROGATE_NAMES[3],
    SurrogateStoreTypes.SurrogateKind.QP: SurrogateStore.SURROGATE_NAMES[4],
}


class SurrogateStoreHandler:
    def __init__(self):
        self.sm_store = SurrogateStore()

    def create_surrogate(self, surrogate_id, surrogate_kind, xt, yt):
        print("CREATE ", surrogate_kind, SURROGATES_MAP[surrogate_kind])
        self.sm_store.create_surrogate(
            surrogate_id, SURROGATES_MAP[surrogate_kind], xt, yt
        )

    def predict_values(self, surrogate_id, x):
        print("PREDICT")
        sm = self.sm_store.get_surrogate(surrogate_id)
        if sm:
            return sm.predict_values(np.array(x))
        else:
            return []

    def destroy_surrogate(self, surrogate_id):
        print("DESTROY")
        self.sm_store.destroy_surrogate(surrogate_id)


handler = SurrogateStoreHandler()
processor = SurrogateStoreService.Processor(handler)
transport = TSocket.TServerSocket("0.0.0.0", port=41400)
tfactory = TTransport.TBufferedTransportFactory()
pfactory = TBinaryProtocol.TBinaryProtocolFactory()

server = TServer.TSimpleServer(processor, transport, tfactory, pfactory)

print("Starting Surrogate server...")
server.serve()
print("done!")
