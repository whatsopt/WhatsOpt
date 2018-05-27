#!/usr/bin/env python

from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift.server import TServer

from server.sellar import Sellar as SellarService
from sellar import Sellar as Factory
from sellar_conversions import *

class SellarHandler:
    def __init__(self):
        factory = Factory()
        self.disc1 = factory.create_disc1()
        self.disc2 = factory.create_disc2()
        self.functions = factory.create_functions()

    def compute_disc1(self, ins):
        return to_thrift_disc1_output(self.disc1.compute(to_openmdao_disc1_inputs(ins)))

    def compute_disc2(self, ins):
        return to_thrift_disc2_output(self.disc2.compute(to_openmdao_disc2_inputs(ins)))

    def compute_functions(self, ins):
        return to_thrift_functions_output(self.functions.compute(to_openmdao_functions_inputs(ins)))


handler = SellarHandler()
processor = SellarService.Processor(handler)
transport = TSocket.TServerSocket(port=30303)
tfactory = TTransport.TBufferedTransportFactory()
pfactory = TBinaryProtocol.TBinaryProtocolFactory()

server = TServer.TSimpleServer(processor, transport, tfactory, pfactory)

print("Starting python server...")
server.serve()
print("done!")