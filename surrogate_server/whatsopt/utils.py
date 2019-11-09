import numpy as np


def r2_score(yv, yp):
    if isinstance(yv, list):
        yv = np.array(yv)

    if isinstance(yp, list):
        yp = np.array(yp)

    if len(yp) < 2:
        return 0.0

    numerator = ((yv - yp) ** 2).sum(axis=0, dtype=np.float64)
    denominator = ((yv - np.average(yv, axis=0)) ** 2).sum(axis=0, dtype=np.float64)

    if denominator == 0:
        return 0.0

    r2 = 1 - numerator / denominator
    return np.average(r2)
