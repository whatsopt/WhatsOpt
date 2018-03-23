import numpy as np
from openmdao.api import Problem, Group, IndepVarComp, ExecComp, NonlinearBlockGS, NewtonSolver, ScipyOptimizeDriver
from openmdao.test_suite.components.sellar import SellarDis1, SellarDis2, SellarDis1withDerivatives, SellarDis2withDerivatives
from smt.sampling_methods import LHS, Random
from smt.extensions import MOE

import matplotlib.pyplot as plt
from matplotlib import colors
from mpl_toolkits.mplot3d import Axes3D

class MySellarDis1(SellarDis1withDerivatives):
    def __init__(self, *args, **kwargs):
        super(MySellarDis1, self).__init__(*args, **kwargs)
        self.nb_calls = 0
        
    def compute(self, i, o):
        super(MySellarDis1, self).compute(i, o)
        self.nb_calls += 1


class SellarMDA(Group):
    """
    Group containing the Sellar MDA.
    """

    def setup(self):
        indeps = self.add_subsystem('indeps', IndepVarComp(), promotes=['*'])
        indeps.add_output('x', 1.0)
        indeps.add_output('z', np.array([5.0, 2.0]))

        cycle = self.add_subsystem('cycle', Group(), promotes=['*'])
        self.d1 = cycle.add_subsystem('d1', MySellarDis1(), promotes_inputs=['x', 'z', 'y2'], promotes_outputs=['y1'])
        self.d2 = cycle.add_subsystem('d2', SellarDis2withDerivatives(), promotes_inputs=['z', 'y1'], promotes_outputs=['y2'])

        # Nonlinear Block Gauss Seidel is a gradient free solver
        cycle.nonlinear_solver = NonlinearBlockGS()

        self.add_subsystem('obj_cmp', ExecComp('obj = x**2 + z[1] + y1 + exp(-y2)',
                           z=np.array([0.0, 0.0]), x=0.0),
                           promotes=['x', 'z', 'y1', 'y2', 'obj'])

        self.add_subsystem('con_cmp1', ExecComp('con1 = 3.16 - y1'), promotes=['con1', 'y1'])
        self.add_subsystem('con_cmp2', ExecComp('con2 = y2 - 24.0'), promotes=['con2', 'y2'])

if __name__ == '__main__':
    
    prob = Problem()
    prob.model = SellarMDA()
    
    
#    prob.driver = ScipyOptimizeDriver()
#     prob.driver.options['optimizer'] = 'SLSQP'
#     # prob.driver.options['maxiter'] = 100
#     prob.driver.options['tol'] = 1e-8
#     
#     prob.model.add_design_var('x', lower=0, upper=10)
#     prob.model.add_design_var('z', lower=0, upper=10)
#     prob.model.add_objective('obj')
#     prob.model.add_constraint('con1', upper=0)
#     prob.model.add_constraint('con2', upper=0)
#     
#     prob.set_solver_print(level=1)
    
    # Ask OpenMDAO to finite-difference across the model to compute the gradients for the optimizer
    #prob.model.approx_totals()
    
    prob.setup()
    xlimits = np.array([[0, 10], [0, 10], [0, 10]])
    sampling = LHS(xlimits=xlimits)
    cases = sampling(50)
    outputs = []
    for case in cases:
        prob['x'] = case[0]
        prob['z'] = case[1:]
        prob.run_model()
        outputs.append(float(prob['obj']))
        
    moe = MOE(smooth_recombination=True, n_clusters=1)
    moe.set_training_values(cases, np.array(outputs))
    moe.train()
        
    np.random.seed(1)
    sampling_test = Random(xlimits=xlimits)
    xtest = sampling_test(50)
    outputs_test = []
    for case in xtest:
        prob['x'] = xtest[0]
        prob['z'] = xtest[1:]
        prob.run_model()
        outputs_test.append(float(prob['obj']))
    ytest = np.array(outputs_test)

    # Prediction
    ypred = moe.predict_values(xtest)
    
    plt.plot(ytest, ytest,'-.')
    plt.plot(ytest, ypred, '.')
    plt.xlabel('actual')
    plt.ylabel('prediction')
    plt.title('Predicted vs Actual')
    plt.show()
        
    print("d1 nb calls = %d" % prob.model.d1.nb_calls)
    