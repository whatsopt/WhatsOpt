import os
import unittest
from openmdao.api import IndepVarComp, Problem, Group
from openmdao.test_suite.components.sellar_feature import SellarDis1, SellarDis2, SellarMDA
from whatsopt.doe_driver import DoeDriver

class TestDoeDriver(unittest.TestCase):

    def setUp(self):
        self.pb = pb = Problem(SellarMDA())
        pb.driver = DoeDriver(sampling_method='LHS', n_cases=50)
        pb.model.add_design_var('x', lower=0, upper=10)
        pb.model.add_design_var('z', lower=0, upper=10)
        pb.setup()
        
    def test_doe_run(self):
        self.pb.run_driver()

if __name__ == '__main__':
    unittest.main()
