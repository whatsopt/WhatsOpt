import numpy as np
import openturns as ot


def compute_thresholding(xdoe, ydoe, thresholding_type, quantile, g_threshold):
    xdoe = np.atleast_2d(xdoe)
    ydoe = np.atleast_2d(ydoe)

    f_obj_arr = ydoe[:, 0:1]
    g_arr = ydoe[:, 1:]
    f_ob_ot = ot.Sample(f_obj_arr)
    Samples = ot.Sample(xdoe)

    #### Threshold definition for the objective function and the constraint
    q = f_ob_ot.computeQuantilePerComponent(quantile)
    # g_threshold = 0.

    ######### THRESHOLDING  #########
    ## Zero-thresholding
    if thresholding_type == "Zero_th":
        f_obj_tot = np.zeros((len(f_obj_arr), 1))
        for i in range(len(f_obj_tot)):
            if f_obj_arr[i] < q and np.all(g_arr[i] <= g_threshold):
                f_obj_tot[i] = f_obj_arr[i]
            else:
                f_obj_tot[i] = 0.0

        f_obj_q = ot.Sample(f_obj_tot)
        Samples_HSIC = Samples

    ## Conditional thresholding
    elif thresholding_type == "Cond_th":
        mask = (f_obj_arr < q) & np.all(g_arr <= g_threshold)
        f_obj_q_arr = f_obj_arr[mask]

        Samples_arr = np.array(Samples)
        Samples_q_arr = Samples_arr[mask.squeeze(), :]

        f_obj_q = ot.Sample(f_obj_q_arr.reshape(-1, 1))
        Samples_q = ot.Sample(Samples_q_arr)
        Samples_HSIC = Samples_q

    ## Indicator-thresholding
    elif thresholding_type == "Ind_th":
        f_obj_tot = np.zeros((len(f_obj_arr), 1))
        for i in range(len(f_obj_tot)):
            if f_obj_arr[i] < q and np.all(g_arr[i] <= g_threshold):
                f_obj_tot[i] = 1.0
            else:
                f_obj_tot[i] = 0.0

        f_obj_q = ot.Sample(f_obj_tot)
        Samples_HSIC = Samples

    return f_obj_q, Samples_HSIC


def compute_hsic(
    xdoe: np.array,
    ydoe: np.array,
    thresholding_type="Zero_th",
    quantile=0.2,
    g_threshold=0.0,
):
    f_obj_q, Samples_HSIC = compute_thresholding(
        xdoe, ydoe, thresholding_type, quantile, g_threshold
    )

    ### definition of the covariance model for the input and the output
    covarianceModelCollection = []
    for i in range(Samples_HSIC.getDimension()):
        Xi = Samples_HSIC.getMarginal(i)
        inputCovariance = ot.SquaredExponential(1)
        inputCovariance.setScale(Xi.computeStandardDeviation())
        covarianceModelCollection.append(inputCovariance)

    outputCovariance = ot.SquaredExponential(1)
    outputCovariance.setScale(f_obj_q.computeStandardDeviation())
    covarianceModelCollection.append(outputCovariance)

    #### Estimation of the HSIC indices
    estimatorType = ot.HSICVStat()
    globHSIC = ot.HSICEstimatorGlobalSensitivity(
        covarianceModelCollection, Samples_HSIC, f_obj_q, estimatorType
    )

    R2HSICIndices = globHSIC.getR2HSICIndices()
    HSICIndices = globHSIC.getHSICIndices()
    pvperm = globHSIC.getPValuesPermutation()
    pvas = globHSIC.getPValuesAsymptotic()

    return R2HSICIndices, HSICIndices, pvperm, pvas
