import unittest
import numpy as np
from whatsopt.surrogate_store import SurrogateStore
from whatsopt.smt_server import Surrogate

SMT_NOT_INSTALLED = False
try:
    from smt.surrogate_models import KRG, LS, QP, RBF
    from smt.extensions import MFK
except:
    SMT_NOT_INSTALLED = True

from thrift import Thrift
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol

from whatsopt.smt_server import Surrogate

class SurrogateProxy(object):
    
    def __init__(self):
        transport = TSocket.TSocket('localhost', 41400)
        transport = TTransport.TBufferedTransport(transport)
        protocol = TBinaryProtocol.TBinaryProtocol(transport)
        self._thrift_client = Surrogate.Client(protocol)
        transport.open()

    def create_analysis_surrogate(self, analysis_id, x, ynames, y):
        self._thrift_client.create_analysis_surrogate(analysis_id, x, ynames, y)

    def predict_values(self, analysis_id, yname, x):
        self._thrift_client.predict_values(analysis_id, yname, x)

class TestSurrogateStore(unittest.TestCase):

    #@unittest.skip("skip")
    def test_create_surrogate(self):
        xt = np.array([[0.0, 1.0, 2.0, 3.0, 4.0]]).T
        yt = np.array([0.0, 1.0, 1.5, 0.5, 1.0]).T

        sm = SurrogateProxy()
        sm.create_analysis_surrogate('1', xt, 'y', yt)

    @unittest.skip("skip")
    def test_save(self):

        xt = np.array([0.0, 1.0, 2.0, 3.0, 4.0])
        yt = np.array([0.0, 1.0, 1.5, 0.5, 1.0])

        sm = KRG()
        sm.set_training_values(xt, yt)
        sm.train()

        num = 13
        x = np.linspace(0.0, 4.0, num)
        y1 = sm.predict_values(x)

        store = SurrogateStore()
        store.save(sm, 1)

        sm2 = store.load(1)
        y2 = sm2.predict_values(x)

        assert np.array_equal(y1, y2)

    @unittest.skip("skip")
    def test_save_mfk(self):

        def LF_function(x):
            import numpy as np
            return 0.5*((x*6-2)**2)*np.sin((x*6-2)*2)+(x-0.5)*10. - 5

        def HF_function(x):
            import numpy as np
            return ((x*6-2)**2)*np.sin((x*6-2)*2)

        # Problem set up
        ndim=1
        Xt_e = np.linspace(0,1, 4, endpoint = True).reshape(-1,ndim)
        Xt_c = np.linspace(0,1, 11, endpoint = True).reshape(-1,ndim)

        nt_exp = Xt_e.shape[0]
        nt_cheap = Xt_c.shape[0]

        # Evaluate the HF and LF functions
        yt_e = HF_function(Xt_e)
        yt_c = LF_function(Xt_c)

        sm = MFK(theta0=np.array(Xt_e.shape[1]*[1.]))

        #low-fidelity dataset names being integers from 0 to level-1
        sm.set_training_values(Xt_c, yt_c, name = 0)
        #high-fidelity dataset without name
        sm.set_training_values(Xt_e, yt_e)

        # train the model
        sm.train()
        #sm.D_all = None
        store = SurrogateStore()
        store.save(sm, 1)
        print(sm.predict_values(np.array([0.314])))

if __name__ == "__main__":
    unittest.main()