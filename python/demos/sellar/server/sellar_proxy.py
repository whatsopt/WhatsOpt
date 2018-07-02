# -*- coding: utf-8 -*-
"""
  sellar_proxy.py generated by WhatsOpt. 
"""
from sellar import Sellar
from sellar_conversions import *

from thrift import Thrift
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol

from sellar_base import SellarBase
from disc1_base import Disc1Base
from disc2_base import Disc2Base
from functions_base import FunctionsBase


class Disc1Proxy(Disc1Base):
    def __init__(self, proxy):
        super(Disc1Proxy, self).__init__()
        self._proxy = proxy
        
    def compute(self, inputs, outputs):
        output = self._proxy.compute_disc1(to_thrift_disc1_input(inputs))
        to_openmdao_disc1_outputs(output, outputs)
class Disc2Proxy(Disc2Base):
    def __init__(self, proxy):
        super(Disc2Proxy, self).__init__()
        self._proxy = proxy
        
    def compute(self, inputs, outputs):
        output = self._proxy.compute_disc2(to_thrift_disc2_input(inputs))
        to_openmdao_disc2_outputs(output, outputs)
class FunctionsProxy(FunctionsBase):
    def __init__(self, proxy):
        super(FunctionsProxy, self).__init__()
        self._proxy = proxy
        
    def compute(self, inputs, outputs):
        output = self._proxy.compute_functions(to_thrift_functions_input(inputs))
        to_openmdao_functions_outputs(output, outputs)



class SellarProxy(SellarBase):
    
    def __init__(self):
        super(SellarProxy, self).__init__()
        transport = TSocket.TSocket('localhost', 31400)
        transport = TTransport.TBufferedTransport(transport)
        protocol = TBinaryProtocol.TBinaryProtocol(transport)
        self._proxy = Sellar.Client(protocol)
        transport.open()

    
    def create_disc1(self):
        return Disc1Proxy(self._proxy)
    
    def create_disc2(self):
        return Disc2Proxy(self._proxy)
    
    def create_functions(self):
        return FunctionsProxy(self._proxy)
    

    def ping(self):
        self._proxy.ping()

    def shutdown(self):
        self._proxy.shutdown()
    