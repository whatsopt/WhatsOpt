import numpy as np
from openmdao.api import Problem, Group, IndepVarComp, ExecComp, NonlinearBlockGS
from openmdao.test_suite.components.sellar import SellarDis1, SellarDis2

class SellarMDA(Group):
    """
    Group containing the Sellar MDA.
    """

    def setup(self):
        indeps = self.add_subsystem('indeps', IndepVarComp(), promotes=['*'])
        indeps.add_output('x', 1.0)
        indeps.add_output('z', np.array([5.0, 2.0]))

        cycle = self.add_subsystem('cycle', Group(), promotes=['*'])
        d1 = cycle.add_subsystem('d1', SellarDis1(), promotes_inputs=['x', 'z', 'y2'], promotes_outputs=['y1'])
        d2 = cycle.add_subsystem('d2', SellarDis2(), promotes_inputs=['z', 'y1'], promotes_outputs=['y2'])

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
    prob.setup()
    
    prob['x'] = 2.
    prob['z'] = [-1., -1.]
    
    prob.run_model()