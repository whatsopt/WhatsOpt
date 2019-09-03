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
from whatsopt.utils import r2_score

SURROGATES_MAP = {
    SurrogateStoreTypes.SurrogateKind.KRIGING: SurrogateStore.SURROGATE_NAMES[0],
    SurrogateStoreTypes.SurrogateKind.KPLS: SurrogateStore.SURROGATE_NAMES[1],
    SurrogateStoreTypes.SurrogateKind.KPLSK: SurrogateStore.SURROGATE_NAMES[2],
    SurrogateStoreTypes.SurrogateKind.LS: SurrogateStore.SURROGATE_NAMES[3],
    SurrogateStoreTypes.SurrogateKind.QP: SurrogateStore.SURROGATE_NAMES[4],
}

NULL_QUALIFICATION = SurrogateStoreTypes.SurrogateQualification(r2=0.0, yp=[])

class SurrogateStoreHandler:
    def __init__(self, outdir="."):
        self.sm_store = SurrogateStore(outdir)

    def ping(self):
        print("Surrogate server... Ping!")

    def shutdown(self):
        exit(0)

    def create_surrogate(self, surrogate_id, surrogate_kind, xt, yt):
        print("CREATE ", surrogate_id, surrogate_kind, SURROGATES_MAP[surrogate_kind])
        try:
            self.sm_store.create_surrogate(
                surrogate_id, SURROGATES_MAP[surrogate_kind], xt, yt
            )
        except Exception as err:
            exc = SurrogateStoreTypes.SurrogateException()
            exc.msg = str(err)
            raise exc

    def qualify(self, surrogate_id, xv, yv):
        print("QUALIFY ", surrogate_id)
        try:
            yp = self.predict_values(surrogate_id, np.array(xv))
            yv = np.array(yv).reshape(yp.shape)
            r2 = r2_score(yv, yp)
            print("R2={}".format(r2))
            return SurrogateStoreTypes.SurrogateQualification(r2=r2, yp=yp)
        except Exception as err:
            exc = SurrogateStoreTypes.SurrogateException()
            exc.msg = str(err)
            raise exc

    def predict_values(self, surrogate_id, x):
        print("PREDICT", surrogate_id)
        try:
            sm = self.sm_store.get_surrogate(surrogate_id)
            if sm:
                return sm.predict_values(np.array(x))
            else:
                return []
        except Exception as err:
            exc = SurrogateStoreTypes.SurrogateException()
            exc.msg = str(err)
            raise exc

    def destroy_surrogate(self, surrogate_id):
        print("DESTROY")
        self.sm_store.destroy_surrogate(surrogate_id)


if __name__ == "__main__":
    from optparse import OptionParser

    parser = OptionParser()
    parser.add_option(
        "-o",
        "--outdir",
        dest="outdir",
        default=".",
        help="save trained surrogate to DIRECTORY",
        metavar="DIRECTORY",
    )
    (options, args) = parser.parse_args()
    outdir = options.outdir
    print("Surrogates saved to {}".format(outdir))
    handler = SurrogateStoreHandler(outdir)
    processor = SurrogateStoreService.Processor(handler)
    transport = TSocket.TServerSocket("0.0.0.0", port=41400)
    tfactory = TTransport.TBufferedTransportFactory()
    pfactory = TBinaryProtocol.TBinaryProtocolFactory()

    server = TServer.TSimpleServer(processor, transport, tfactory, pfactory)

    print("Starting Surrogate server...")
    server.serve()
    print("done!")
