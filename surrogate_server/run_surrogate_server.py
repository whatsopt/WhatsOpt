# -*- coding: utf-8 -*-
#!/usr/bin/env python

import numpy as np

from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift.server import TServer

from whatsopt.smt_server import Surrogate as SurrogateService
from smt.surrogate_models import KRG, LS, QP, RBF

class SurrogateHandler:

    def __init__(self):
        pass

    def create_analysis_surrogate(self, analysis_id, xt, ynames, yt):
        sm = KRG(data_dir='cache')
        sm.set_training_values(np.array(xt), np.array(yt))
        sm.train()

        print(analysis_id, xt, ynames, yt)

    def predict_values(self, analysis_id, yname, x):
        pass

handler = SurrogateHandler()
processor = SurrogateService.Processor(handler)
transport = TSocket.TServerSocket('0.0.0.0', port=41400)
tfactory = TTransport.TBufferedTransportFactory()
pfactory = TBinaryProtocol.TBinaryProtocolFactory()

server = TServer.TSimpleServer(processor, transport, tfactory, pfactory)

print("Starting Surrogate server...")
server.serve()
print("done!")
