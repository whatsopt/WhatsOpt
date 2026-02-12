#!/usr/bin/env python
import sys
import tempfile

from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift.server import TServer
from thrift.TMultiplexedProcessor import TMultiplexedProcessor

from whatsopt_server.handlers.administration_handler import AdministrationHandler
from whatsopt_server.services import Administration as AdministrationService
from whatsopt_server.handlers.surrogate_store_handler import SurrogateStoreHandler
from whatsopt_server.services import SurrogateStore as SurrogateStoreService

import warnings

warnings.simplefilter(action="ignore", category=FutureWarning)


def main(args=sys.argv[1:]):
    from optparse import OptionParser

    parser = OptionParser()
    parser.add_option(
        "-o",
        "--outdir",
        dest="outdir",
        default=tempfile.gettempdir(),
        help="save trained surrogates to DIRECTORY",
        metavar="DIRECTORY",
    )
    parser.add_option(
        "--logdir",
        dest="logdir",
        default=tempfile.gettempdir(),
        help="save logs to DIRECTORY",
        metavar="DIRECTORY",
    )
    parser.add_option(
        "--port",
        dest="port",
        default=41400,
        help="port to listen on",
        metavar="PORT",
    )
    (options, args) = parser.parse_args(args)
    outdir = options.outdir
    logdir = options.logdir
    port = int(options.port)
    print("Surrogates saved to {}".format(outdir))
    print("Logs saved to {}".format(logdir))
    print("Listening on port {}".format(port))

    processor = TMultiplexedProcessor()
    processor.registerProcessor(
        "SurrogateStoreService",
        SurrogateStoreService.Processor(SurrogateStoreHandler(outdir=outdir)),
    )
    processor.registerProcessor(
        "AdministrationService",
        AdministrationService.Processor(AdministrationHandler()),
    )
    transport = TSocket.TServerSocket("0.0.0.0", port=port)
    tfactory = TTransport.TBufferedTransportFactory()
    pfactory = TBinaryProtocol.TBinaryProtocolFactory()

    server = TServer.TSimpleServer(processor, transport, tfactory, pfactory)

    print("Starting WhatsOpt services...")
    server.serve()
    print("done!")


if __name__ == "__main__":
    main(sys.argv[1:])
