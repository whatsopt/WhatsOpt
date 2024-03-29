#
# Autogenerated by Thrift Compiler (0.20.0)
#
# DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
#
#  options string: py
#

from thrift.Thrift import TType, TMessageType, TApplicationException
from thrift.TRecursive import fix_spec

import logging
from .ttypes import *
from thrift.Thrift import TProcessor
from thrift.transport import TTransport

all_structs = []


class Iface(object):
    def compute_hsic(self, xdoe, ydoe, thresholding_type, quantile, g_threshold):
        """
        Parameters:
         - xdoe
         - ydoe
         - thresholding_type
         - quantile
         - g_threshold

        """
        pass


class Client(Iface):
    def __init__(self, iprot, oprot=None):
        self._iprot = self._oprot = iprot
        if oprot is not None:
            self._oprot = oprot
        self._seqid = 0

    def compute_hsic(self, xdoe, ydoe, thresholding_type, quantile, g_threshold):
        """
        Parameters:
         - xdoe
         - ydoe
         - thresholding_type
         - quantile
         - g_threshold

        """
        self.send_compute_hsic(xdoe, ydoe, thresholding_type, quantile, g_threshold)
        return self.recv_compute_hsic()

    def send_compute_hsic(self, xdoe, ydoe, thresholding_type, quantile, g_threshold):
        self._oprot.writeMessageBegin("compute_hsic", TMessageType.CALL, self._seqid)
        args = compute_hsic_args()
        args.xdoe = xdoe
        args.ydoe = ydoe
        args.thresholding_type = thresholding_type
        args.quantile = quantile
        args.g_threshold = g_threshold
        args.write(self._oprot)
        self._oprot.writeMessageEnd()
        self._oprot.trans.flush()

    def recv_compute_hsic(self):
        iprot = self._iprot
        (fname, mtype, rseqid) = iprot.readMessageBegin()
        if mtype == TMessageType.EXCEPTION:
            x = TApplicationException()
            x.read(iprot)
            iprot.readMessageEnd()
            raise x
        result = compute_hsic_result()
        result.read(iprot)
        iprot.readMessageEnd()
        if result.success is not None:
            return result.success
        raise TApplicationException(
            TApplicationException.MISSING_RESULT, "compute_hsic failed: unknown result"
        )


class Processor(Iface, TProcessor):
    def __init__(self, handler):
        self._handler = handler
        self._processMap = {}
        self._processMap["compute_hsic"] = Processor.process_compute_hsic
        self._on_message_begin = None

    def on_message_begin(self, func):
        self._on_message_begin = func

    def process(self, iprot, oprot):
        (name, type, seqid) = iprot.readMessageBegin()
        if self._on_message_begin:
            self._on_message_begin(name, type, seqid)
        if name not in self._processMap:
            iprot.skip(TType.STRUCT)
            iprot.readMessageEnd()
            x = TApplicationException(
                TApplicationException.UNKNOWN_METHOD, "Unknown function %s" % (name)
            )
            oprot.writeMessageBegin(name, TMessageType.EXCEPTION, seqid)
            x.write(oprot)
            oprot.writeMessageEnd()
            oprot.trans.flush()
            return
        else:
            self._processMap[name](self, seqid, iprot, oprot)
        return True

    def process_compute_hsic(self, seqid, iprot, oprot):
        args = compute_hsic_args()
        args.read(iprot)
        iprot.readMessageEnd()
        result = compute_hsic_result()
        try:
            result.success = self._handler.compute_hsic(
                args.xdoe,
                args.ydoe,
                args.thresholding_type,
                args.quantile,
                args.g_threshold,
            )
            msg_type = TMessageType.REPLY
        except TTransport.TTransportException:
            raise
        except TApplicationException as ex:
            logging.exception("TApplication exception in handler")
            msg_type = TMessageType.EXCEPTION
            result = ex
        except Exception:
            logging.exception("Unexpected exception in handler")
            msg_type = TMessageType.EXCEPTION
            result = TApplicationException(
                TApplicationException.INTERNAL_ERROR, "Internal error"
            )
        oprot.writeMessageBegin("compute_hsic", msg_type, seqid)
        result.write(oprot)
        oprot.writeMessageEnd()
        oprot.trans.flush()


# HELPER FUNCTIONS AND STRUCTURES


class compute_hsic_args(object):
    """
    Attributes:
     - xdoe
     - ydoe
     - thresholding_type
     - quantile
     - g_threshold

    """

    def __init__(
        self,
        xdoe=None,
        ydoe=None,
        thresholding_type=None,
        quantile=None,
        g_threshold=None,
    ):
        self.xdoe = xdoe
        self.ydoe = ydoe
        self.thresholding_type = thresholding_type
        self.quantile = quantile
        self.g_threshold = g_threshold

    def read(self, iprot):
        if (
            iprot._fast_decode is not None
            and isinstance(iprot.trans, TTransport.CReadableTransport)
            and self.thrift_spec is not None
        ):
            iprot._fast_decode(self, iprot, [self.__class__, self.thrift_spec])
            return
        iprot.readStructBegin()
        while True:
            (fname, ftype, fid) = iprot.readFieldBegin()
            if ftype == TType.STOP:
                break
            if fid == 1:
                if ftype == TType.LIST:
                    self.xdoe = []
                    (_etype291, _size288) = iprot.readListBegin()
                    for _i292 in range(_size288):
                        _elem293 = []
                        (_etype297, _size294) = iprot.readListBegin()
                        for _i298 in range(_size294):
                            _elem299 = iprot.readDouble()
                            _elem293.append(_elem299)
                        iprot.readListEnd()
                        self.xdoe.append(_elem293)
                    iprot.readListEnd()
                else:
                    iprot.skip(ftype)
            elif fid == 2:
                if ftype == TType.LIST:
                    self.ydoe = []
                    (_etype303, _size300) = iprot.readListBegin()
                    for _i304 in range(_size300):
                        _elem305 = []
                        (_etype309, _size306) = iprot.readListBegin()
                        for _i310 in range(_size306):
                            _elem311 = iprot.readDouble()
                            _elem305.append(_elem311)
                        iprot.readListEnd()
                        self.ydoe.append(_elem305)
                    iprot.readListEnd()
                else:
                    iprot.skip(ftype)
            elif fid == 3:
                if ftype == TType.I32:
                    self.thresholding_type = iprot.readI32()
                else:
                    iprot.skip(ftype)
            elif fid == 4:
                if ftype == TType.DOUBLE:
                    self.quantile = iprot.readDouble()
                else:
                    iprot.skip(ftype)
            elif fid == 5:
                if ftype == TType.DOUBLE:
                    self.g_threshold = iprot.readDouble()
                else:
                    iprot.skip(ftype)
            else:
                iprot.skip(ftype)
            iprot.readFieldEnd()
        iprot.readStructEnd()

    def write(self, oprot):
        if oprot._fast_encode is not None and self.thrift_spec is not None:
            oprot.trans.write(
                oprot._fast_encode(self, [self.__class__, self.thrift_spec])
            )
            return
        oprot.writeStructBegin("compute_hsic_args")
        if self.xdoe is not None:
            oprot.writeFieldBegin("xdoe", TType.LIST, 1)
            oprot.writeListBegin(TType.LIST, len(self.xdoe))
            for iter312 in self.xdoe:
                oprot.writeListBegin(TType.DOUBLE, len(iter312))
                for iter313 in iter312:
                    oprot.writeDouble(iter313)
                oprot.writeListEnd()
            oprot.writeListEnd()
            oprot.writeFieldEnd()
        if self.ydoe is not None:
            oprot.writeFieldBegin("ydoe", TType.LIST, 2)
            oprot.writeListBegin(TType.LIST, len(self.ydoe))
            for iter314 in self.ydoe:
                oprot.writeListBegin(TType.DOUBLE, len(iter314))
                for iter315 in iter314:
                    oprot.writeDouble(iter315)
                oprot.writeListEnd()
            oprot.writeListEnd()
            oprot.writeFieldEnd()
        if self.thresholding_type is not None:
            oprot.writeFieldBegin("thresholding_type", TType.I32, 3)
            oprot.writeI32(self.thresholding_type)
            oprot.writeFieldEnd()
        if self.quantile is not None:
            oprot.writeFieldBegin("quantile", TType.DOUBLE, 4)
            oprot.writeDouble(self.quantile)
            oprot.writeFieldEnd()
        if self.g_threshold is not None:
            oprot.writeFieldBegin("g_threshold", TType.DOUBLE, 5)
            oprot.writeDouble(self.g_threshold)
            oprot.writeFieldEnd()
        oprot.writeFieldStop()
        oprot.writeStructEnd()

    def validate(self):
        return

    def __repr__(self):
        L = ["%s=%r" % (key, value) for key, value in self.__dict__.items()]
        return "%s(%s)" % (self.__class__.__name__, ", ".join(L))

    def __eq__(self, other):
        return isinstance(other, self.__class__) and self.__dict__ == other.__dict__

    def __ne__(self, other):
        return not (self == other)


all_structs.append(compute_hsic_args)
compute_hsic_args.thrift_spec = (
    None,  # 0
    (
        1,
        TType.LIST,
        "xdoe",
        (TType.LIST, (TType.DOUBLE, None, False), False),
        None,
    ),  # 1
    (
        2,
        TType.LIST,
        "ydoe",
        (TType.LIST, (TType.DOUBLE, None, False), False),
        None,
    ),  # 2
    (
        3,
        TType.I32,
        "thresholding_type",
        None,
        None,
    ),  # 3
    (
        4,
        TType.DOUBLE,
        "quantile",
        None,
        None,
    ),  # 4
    (
        5,
        TType.DOUBLE,
        "g_threshold",
        None,
        None,
    ),  # 5
)


class compute_hsic_result(object):
    """
    Attributes:
     - success

    """

    def __init__(
        self,
        success=None,
    ):
        self.success = success

    def read(self, iprot):
        if (
            iprot._fast_decode is not None
            and isinstance(iprot.trans, TTransport.CReadableTransport)
            and self.thrift_spec is not None
        ):
            iprot._fast_decode(self, iprot, [self.__class__, self.thrift_spec])
            return
        iprot.readStructBegin()
        while True:
            (fname, ftype, fid) = iprot.readFieldBegin()
            if ftype == TType.STOP:
                break
            if fid == 0:
                if ftype == TType.STRUCT:
                    self.success = HsicAnalysis()
                    self.success.read(iprot)
                else:
                    iprot.skip(ftype)
            else:
                iprot.skip(ftype)
            iprot.readFieldEnd()
        iprot.readStructEnd()

    def write(self, oprot):
        if oprot._fast_encode is not None and self.thrift_spec is not None:
            oprot.trans.write(
                oprot._fast_encode(self, [self.__class__, self.thrift_spec])
            )
            return
        oprot.writeStructBegin("compute_hsic_result")
        if self.success is not None:
            oprot.writeFieldBegin("success", TType.STRUCT, 0)
            self.success.write(oprot)
            oprot.writeFieldEnd()
        oprot.writeFieldStop()
        oprot.writeStructEnd()

    def validate(self):
        return

    def __repr__(self):
        L = ["%s=%r" % (key, value) for key, value in self.__dict__.items()]
        return "%s(%s)" % (self.__class__.__name__, ", ".join(L))

    def __eq__(self, other):
        return isinstance(other, self.__class__) and self.__dict__ == other.__dict__

    def __ne__(self, other):
        return not (self == other)


all_structs.append(compute_hsic_result)
compute_hsic_result.thrift_spec = (
    (
        0,
        TType.STRUCT,
        "success",
        [HsicAnalysis, None],
        None,
    ),  # 0
)
fix_spec(all_structs)
del all_structs
