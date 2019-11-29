import numpy as np

# from whatsopt.utils import r2_score
from sklearn.metrics import r2_score

from whatsopt.surrogate_server import ttypes as SurrogateStoreTypes
from .surrogate_store import SurrogateStore

SURROGATES_MAP = {
    SurrogateStoreTypes.SurrogateKind.KRIGING: SurrogateStore.SURROGATE_NAMES[0],
    SurrogateStoreTypes.SurrogateKind.KPLS: SurrogateStore.SURROGATE_NAMES[1],
    SurrogateStoreTypes.SurrogateKind.KPLSK: SurrogateStore.SURROGATE_NAMES[2],
    SurrogateStoreTypes.SurrogateKind.LS: SurrogateStore.SURROGATE_NAMES[3],
    SurrogateStoreTypes.SurrogateKind.QP: SurrogateStore.SURROGATE_NAMES[4],
}

NULL_QUALIFICATION = SurrogateStoreTypes.SurrogateQualification(r2=0.0, yp=[])


def throw_surrogate_exception(func):
    def func_wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except Exception as err:
            exc = SurrogateStoreTypes.SurrogateException()
            exc.msg = str(err)
            raise exc

    return func_wrapper


class SurrogateServerHandler:
    def __init__(self, outdir="."):
        self.sm_store = SurrogateStore(outdir)

    def ping(self):
        print("Surrogate server... Ping!")

    def shutdown(self):
        exit(0)

    @throw_surrogate_exception
    def create_surrogate(self, surrogate_id, surrogate_kind, xt, yt):
        print("CREATE ", surrogate_id, surrogate_kind, SURROGATES_MAP[surrogate_kind])
        self.sm_store.create_surrogate(
            surrogate_id, SURROGATES_MAP[surrogate_kind], xt, yt
        )

    @throw_surrogate_exception
    def qualify(self, surrogate_id, xv, yv):
        print("QUALIFY ", surrogate_id)
        yp = self.predict_values(surrogate_id, np.array(xv))
        yv = np.array(yv).reshape(yp.shape)
        r2 = r2_score(yv, yp)
        print("R2={}".format(r2))
        return SurrogateStoreTypes.SurrogateQualification(r2=r2, yp=yp)

    @throw_surrogate_exception
    def predict_values(self, surrogate_id, x):
        print("PREDICT", surrogate_id)
        sm = self.sm_store.get_surrogate(surrogate_id)
        if sm:
            return sm.predict_values(np.array(x))
        else:
            return []

    def destroy_surrogate(self, surrogate_id):
        print("DESTROY")
        self.sm_store.destroy_surrogate(surrogate_id)

    @throw_surrogate_exception
    def copy_surrogate(self, src_id, dst_id):
        print("COPY from surrogate {} to surrogate {}".format(src_id, dst_id))
        self.sm_store.copy_surrogate(src_id, dst_id)
