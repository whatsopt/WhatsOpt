import sys
import numpy as np
from smt.surrogate_models.surrogate_model import SurrogateModel
import openturns as ot


class SurrogateOpenturnsException(Exception):
    pass


class PCE(SurrogateModel):
    def _initialize(self):
        super(PCE, self)._initialize()
        self.name = "OPENTURNS_PCE"
        declare = self.options.declare

        declare("pce_degree", default=3, types=int, desc="Degree of chaos polynoms")

        declare(
            "distribution_specs",
            default=None,
            types=list,
            desc="list of Openturns Dsitribution spec {name: ClassName, kwargs: **kwargs}",
        )

    def train(self):
        input_dim = self.training_points[None][0][0].shape[1]
        x_train = ot.Sample(self.training_points[None][0][0])
        y_train = ot.Sample(self.training_points[None][0][1])

        # Distribution choice of the inputs to Create the input distribution
        distributions = []
        dist_specs = self.options["distribution_specs"]
        if dist_specs:
            if len(dist_specs) != input_dim:
                raise SurrogateOpenturnsException(
                    "Number of distributions should be equal to input \
                        dimensions. Should be {}, got {}".format(
                        input_dim, len(dist_specs)
                    )
                )
            for ds in dist_specs:
                dist_klass = getattr(sys.modules[__name__], ds["name"])
                distributions.append(dist_klass(**ds["kwargs"]))
        else:
            for i in range(input_dim):
                mean = np.mean(x_train[:, i])
                distributions.append(ot.Uniform(0.95 * mean, 1.05 * mean))

        distribution = ot.ComposedDistribution(distributions)

        # Polynomial basis
        # step 1 - Construction of the multivariate orthonormal basis:
        # Build orthonormal or orthogonal univariate polynomial families
        # (associated to associated input distribution)
        polynoms = [0.0] * input_dim
        for i in range(distribution.getDimension()):
            polynoms[i] = ot.StandardDistributionPolynomialFactory(
                distribution.getMarginal(i)
            )
        enumerateFunction = ot.LinearEnumerateFunction(input_dim)
        productBasis = ot.OrthogonalProductPolynomialFactory(
            polynoms, enumerateFunction
        )

        # step 2 - Truncation strategy of the multivariate orthonormal basis:
        # a strategy must be chosen for the selection of the different terms
        # of the multivariate basis.
        # Truncature strategy of the multivariate orthonormal basis
        # We choose all the polynomials of degree <= degree
        degree = self.options["pce_degree"]
        index_max = enumerateFunction.getStrataCumulatedCardinal(degree)
        adaptive_strategy = ot.FixedStrategy(productBasis, index_max)

        basis_sequenceFactory = ot.LARS()
        fitting_algorithm = ot.CorrectedLeaveOneOut()
        approximation_algorithm = ot.LeastSquaresMetaModelSelectionFactory(
            basis_sequenceFactory, fitting_algorithm
        )
        projection_strategy = ot.LeastSquaresStrategy(
            x_train, y_train, approximation_algorithm
        )

        algo = ot.FunctionalChaosAlgorithm(
            x_train, y_train, distribution, adaptive_strategy, projection_strategy
        )
        # algo = ot.FunctionalChaosAlgorithm(X_train_NS, Y_train_NS)
        algo.run()
        self._pce_result = algo.getResult()

    def predict_values(self, x):
        mm = self._pce_result.getMetaModel()
        return np.array(mm(x))

