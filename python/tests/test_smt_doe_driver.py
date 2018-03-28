import os
import unittest
from openmdao.api import IndepVarComp, Problem, Group, SqliteRecorder, CaseReader
from openmdao.test_suite.components.sellar_feature import SellarDis1, SellarDis2, SellarMDA
from whatsopt.smt_doe_driver import SmtDoeDriver

class TestSmtDoeDriver(unittest.TestCase):

    def setUp(self):
        self.pb = pb = Problem(SellarMDA())
        pb.driver = SmtDoeDriver(sampling_method='LHS', n_cases=10)
        
        self.case_recorder_filename = 'test_smt_doe_driver.sqlite'
        recorder = SqliteRecorder(self.case_recorder_filename)

        pb.model.add_recorder(recorder)
        pb.model.nonlinear_solver.add_recorder(recorder)
        
        pb.setup()
        
    def tearDown(self):
        pass #os.remove(self.case_recorder_filename)
        
    def test_doe_run(self):
        self.pb.run_driver()
        assert os.path.exists(self.case_recorder_filename)
        reader = CaseReader(self.case_recorder_filename)
        for case_id in reader.system_cases.list_cases():
            case = reader.system_cases.get_case(case_id)
            print(case.inputs['x'])
            print(case.inputs['z'])
            print(case.outputs['y1'])
            print(case.outputs['y2'])
            print(case.outputs['con1'])
            print(case.outputs['con2'])
            print(case.outputs['obj'])

if __name__ == '__main__':
    unittest.main()
