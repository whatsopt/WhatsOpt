# -*- coding: utf-8 -*-
"""
  run_doe.py generated by WhatsOpt. 
"""
# DO NOT EDIT unless you know what you are doing
# analysis_id: 109

import numpy as np
# import matplotlib
# matplotlib.use('Agg')
import matplotlib.pyplot as plt
from openmdao.api import Problem, SqliteRecorder, CaseReader
from whatsopt.smt_doe_driver import SmtDoeDriver
from sellar import Sellar 

from optparse import OptionParser
parser = OptionParser()
parser.add_option("-b", "--batch",
                  action="store_true", dest="batch", default=False,
                  help="do not plot anything")
(options, args) = parser.parse_args()

pb = Problem(Sellar())
pb.driver = SmtDoeDriver(sampling_method='LHS', n_cases=10)
case_recorder_filename = 'sellar_doe.sqlite'        
recorder = SqliteRecorder(case_recorder_filename)
pb.driver.add_recorder(recorder)
pb.model.add_recorder(recorder)
pb.model.nonlinear_solver.add_recorder(recorder)


pb.model.add_design_var('x', lower=0, upper=10)
pb.model.add_design_var('z', lower=0, upper=10)

pb.model.add_objective('obj')


pb.model.add_constraint('g1', upper=0.)
pb.model.add_constraint('g2', upper=0.)

pb.setup()  
pb.run_driver()        

if options.batch:
    exit(0)
reader = CaseReader(case_recorder_filename)
cases = reader.system_cases.list_cases()
n = len(cases)
data = {'inputs': {}, 'outputs': {} }

data['inputs']['x'] = np.zeros((n,)+(1,))
data['inputs']['z'] = np.zeros((n,)+(2,))

data['outputs']['obj'] = np.zeros((n,)+(1,))
data['outputs']['g1'] = np.zeros((n,)+(1,))
data['outputs']['g2'] = np.zeros((n,)+(1,))

for i, case_id in enumerate(cases):
    case = reader.system_cases.get_case(case_id)
    data['inputs']['x'][i,:] = case.inputs['x']
    data['inputs']['z'][i,:] = case.inputs['z']
    data['outputs']['obj'][i,:] = case.outputs['obj']
    data['outputs']['g1'][i,:] = case.outputs['g1']
    data['outputs']['g2'][i,:] = case.outputs['g2']
      

output = data['outputs']['obj'].reshape(-1)

input = data['inputs']['x'].reshape(-1)
plt.subplot(3, 3, 1)
plt.plot(input[0::1], output[0::1], '.')
plt.ylabel('obj')
plt.xlabel('x')

input = data['inputs']['z'].reshape(-1)
plt.subplot(3, 3, 2)
plt.plot(input[0::2], output[0::1], '.')
plt.xlabel('z 0')
plt.subplot(3, 3, 3)
plt.plot(input[1::2], output[0::1], '.')
plt.xlabel('z 1')


output = data['outputs']['g1'].reshape(-1)

input = data['inputs']['x'].reshape(-1)
plt.subplot(3, 3, 4)
plt.plot(input[0::1], output[0::1], '.')
plt.ylabel('g1')
plt.xlabel('x')

input = data['inputs']['z'].reshape(-1)
plt.subplot(3, 3, 5)
plt.plot(input[0::2], output[0::1], '.')
plt.xlabel('z 0')
plt.subplot(3, 3, 6)
plt.plot(input[1::2], output[0::1], '.')
plt.xlabel('z 1')


output = data['outputs']['g2'].reshape(-1)

input = data['inputs']['x'].reshape(-1)
plt.subplot(3, 3, 7)
plt.plot(input[0::1], output[0::1], '.')
plt.ylabel('g2')
plt.xlabel('x')

input = data['inputs']['z'].reshape(-1)
plt.subplot(3, 3, 8)
plt.plot(input[0::2], output[0::1], '.')
plt.xlabel('z 0')
plt.subplot(3, 3, 9)
plt.plot(input[1::2], output[0::1], '.')
plt.xlabel('z 1')

plt.show()
