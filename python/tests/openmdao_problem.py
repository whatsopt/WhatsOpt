from openmdao.api import IndepVarComp, Problem, Group
from openmdao.test_suite.components.paraboloid import Paraboloid

pb = Problem()
root = pb.model = Group()
root.add_subsystem('p1', IndepVarComp('x', 3.0))
root.add_subsystem('p2', IndepVarComp('y', -4.0))
root.add_subsystem('p', Paraboloid())
root.connect('p1.x', 'p.x')
root.connect('p2.y', 'p.y')
pb.setup()

if __name__ == '__main__':
    pb.run_model()
    print pb['p.f_xy']