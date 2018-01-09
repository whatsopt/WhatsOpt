import os
import unittest
from openmdao.api import IndepVarComp, Problem, Group
from openmdao.test_suite.components.sellar import SellarDis1, SellarDis2
from whatsopt.whatsopt_client import WhatsOpt

class TestWhatsOptClient(unittest.TestCase):

    def setUp(self):
        self.setup_problem_example()
        self.wopt = WhatsOpt()

    def test_list_analyses(self):
        self.wopt.list()

if __name__ == '__main__':
    unittest.main()
