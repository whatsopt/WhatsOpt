
from whatsopt_server.computations.hsic import compute_hsic
from whatsopt_server.services import ttypes as SensibilityAnalyserTypes

THRESHOLDING_MAP = {
    SensibilityAnalyserTypes.HsicThresholding.ZERO : "Zero_th",
    SensibilityAnalyserTypes.HsicThresholding.COND : "Cond_th",
    SensibilityAnalyserTypes.HsicThresholding.IND  : "Ind_th",
}

class SensitivityAnalyserHandler:
    
    def compute_hsic(self, xdoe, ydoe, thresholding_type, quantile, g_threshold):
        r2, indices, pvperm, pvas = compute_hsic(xdoe, ydoe, THRESHOLDING_MAP[thresholding_type], quantile, g_threshold)
        return SensibilityAnalyserTypes.HsicAnalysis(r2=r2, indices=indices, pvperm=pvperm, pvas=pvas)