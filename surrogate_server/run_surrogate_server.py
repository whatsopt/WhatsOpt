# -*- coding: utf-8 -*-
#!/usr/bin/env python
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift.server import TServer

from whatsopt.surrogate_server_handler import SurrogateServerHandler
from whatsopt.surrogate_server import SurrogateStore as SurrogateStoreService

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
    handler = SurrogateServerHandler(outdir)
    processor = SurrogateStoreService.Processor(handler)
    transport = TSocket.TServerSocket("0.0.0.0", port=41400)
    tfactory = TTransport.TBufferedTransportFactory()
    pfactory = TBinaryProtocol.TBinaryProtocolFactory()

    server = TServer.TSimpleServer(processor, transport, tfactory, pfactory)

    print("Starting Surrogate server...")
    server.serve()
    print("done!")
