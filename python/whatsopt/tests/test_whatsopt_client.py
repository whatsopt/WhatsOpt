import unittest
from openmdao.api import IndepVarComp, Problem, Group
from openmdao.test_suite.components.paraboloid import Paraboloid
from whatsopt.client import WhatsOpt

class TestWhatsOptClient(unittest.TestCase):

    def setup_problem_example(self):
        self.pb = Problem()
        root = self.pb.model = Group()
        root.add_subsystem('p1', IndepVarComp('x', 3.0))
        root.add_subsystem('p2', IndepVarComp('y', -4.0))
        root.add_subsystem('p', Paraboloid())
        root.connect('p1.x', 'p.x')
        root.connect('p2.y', 'p.y')
        self.pb.setup(False)

    def setUp(self):
        self.setup_problem_example()
        wopt_url = "http://192.168.99.100:3000"
        wopt_key = "47f2cd8c8ea3e8b72ee48324e773b2fd"
        self.wopt = WhatsOpt(wopt_url)

    def test_import_mda(self):
        self.wopt.import_mda(self.pb)

#     def test_list_studies(self):
#         studies = self.wopt.list_studies()
#         # print studies
#         self.assertTrue(self._isStudyPresent(studies))
# 
#     def _isStudyPresent(self, studies):
#         data = _get_viewer_data(self.pb)
#         # print 'TREE', data['tree']
#         # print 'CONNS', data['connections_list']
#         for study in studies:
#             print study
#             if study['tree_json'] == data['tree'] and study['conns_json'] == data['connections_list']:
#                 return True
#         return False

if __name__ == '__main__':
    unittest.main()
