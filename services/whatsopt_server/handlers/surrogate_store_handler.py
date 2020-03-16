import numpy as np

# from whatsopt.utils import r2_score
from sklearn.metrics import r2_score

from whatsopt_server.services import ttypes as SurrogateStoreTypes
from whatsopt_server.surrogate_store.surrogate_store import SurrogateStore

SURROGATES_MAP = {
    SurrogateStoreTypes.SurrogateKind.SMT_KRIGING: SurrogateStore.SURROGATE_NAMES[0],
    SurrogateStoreTypes.SurrogateKind.SMT_KPLS: SurrogateStore.SURROGATE_NAMES[1],
    SurrogateStoreTypes.SurrogateKind.SMT_KPLSK: SurrogateStore.SURROGATE_NAMES[2],
    SurrogateStoreTypes.SurrogateKind.SMT_LS: SurrogateStore.SURROGATE_NAMES[3],
    SurrogateStoreTypes.SurrogateKind.SMT_QP: SurrogateStore.SURROGATE_NAMES[4],
    SurrogateStoreTypes.SurrogateKind.OPENTURNS_PCE: SurrogateStore.SURROGATE_NAMES[5],
}

NULL_QUALIFICATION = SurrogateStoreTypes.SurrogateQualification(r2=0.0, yp=[])


def throw_surrogate_exception(func):
    def func_wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except Exception as err:
            print(err)
            exc = SurrogateStoreTypes.SurrogateException()
            exc.msg = str(err)
            raise exc

    return func_wrapper


class SurrogateStoreHandler:
    def __init__(self, outdir="."):
        self.sm_store = SurrogateStore(outdir)

    def ping(self):
        print("Surrogate server... Ping!")

    def shutdown(self):
        exit(0)

    @throw_surrogate_exception
    def create_surrogate(
        self,
        surrogate_id,
        surrogate_kind,
        xt,
        yt,
        surrogate_options={},
        uncertainties=[],
    ):
        print(
            "CREATE ",
            surrogate_id,
            surrogate_kind,
            SURROGATES_MAP[surrogate_kind],
            surrogate_options,
        )
        surrogate_opts = {}
        for k, v in surrogate_options.items():
            if v.integer is not None:
                surrogate_opts[k] = v.integer
            if v.number is not None:
                surrogate_opts[k] = v.number
            if v.vector is not None:
                surrogate_opts[k] = v.vector
            if v.str is not None:
                surrogate_opts[k] = v.str
        uncertains = [
            {"name": dist.name, "kwargs": dist.kwargs} for dist in uncertainties
        ]
        self.sm_store.create_surrogate(
            surrogate_id,
            SURROGATES_MAP[surrogate_kind],
            xt,
            yt,
            surrogate_opts,
            uncertains,
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

    @throw_surrogate_exception
    def get_sobol_pce_sensitivity_analysis(self, surrogate_id):
        print("GET SOBOL INDICES from surrogate {}".format(surrogate_id))
        sobols = self.sm_store.get_sobol_pce_sensitivity_analysis(surrogate_id)
        return SurrogateStoreTypes.SobolIndices(S1=sobols["S1"], ST=sobols["ST"])
