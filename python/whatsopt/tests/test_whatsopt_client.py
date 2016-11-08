import unittest
from openmdao.api import IndepVarComp, Problem, Group
from openmdao.examples.paraboloid_example import Paraboloid
from openmdao.devtools.partition_tree_n2 import get_model_viewer_data
from whatsopt.client import WhatsOpt


class TestWhatsOptClient(unittest.TestCase):

    def setup_problem_example(self):
        self.pb = Problem()
        root = self.pb.root = Group()
        root.add('p1', IndepVarComp('x', 3.0))
        root.add('p2', IndepVarComp('y', -4.0))
        root.add('p', Paraboloid())
        root.connect('p1.x', 'p.x')
        root.connect('p2.y', 'p.y')
        self.pb.setup(False)

    def setUp(self):
        self.setup_problem_example()
        wopt_url = "http://127.0.0.1:3000/api/v1"
        wopt_key = "47f2cd8c8ea3e8b72ee48324e773b2fd"
        self.wopt = WhatsOpt(wopt_url, wopt_key)

    def test_store_study(self):
        self.wopt.store(self.pb)

    def test_list_studies(self):
        studies = self.wopt.list_studies()
        # print studies
        self.assertTrue(self._isStudyPresent(studies))

    def _isStudyPresent(self, studies):
        data = get_model_viewer_data(self.pb)
        # print 'TREE', data['tree']
        # print 'CONNS', data['connections_list']
        for study in studies:
            print study
            if study['tree_json'] == data['tree'] and study['conns_json'] == data['connections_list']:
                return True
        return False

if __name__ == '__main__':
    unittest.main()
