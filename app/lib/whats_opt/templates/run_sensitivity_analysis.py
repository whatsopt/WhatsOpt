# DO NOT EDIT unless you know what you are doing
# analysis_id: <%= @mda.id %>

import sys
import numpy as np
# import matplotlib
# matplotlib.use('Agg')
import matplotlib.pyplot as plt

from SALib.analyze import morris as ma
from SALib.plotting import morris as mp

inputs = np.array([[0, 1. / 3], [0, 1], [2. / 3, 1],
                        [0, 1. / 3], [2. / 3, 1. / 3], [2. / 3, 1],
                        [2. / 3, 0], [2. / 3, 2. / 3], [0, 2. / 3],
                        [1. / 3, 1], [1, 1], [1, 1. / 3],
                        [1. / 3, 1], [1. / 3, 1. / 3], [1, 1. / 3],
                        [1. / 3, 2. / 3], [1. / 3, 0], [1, 0]],
                        dtype=np.float)

outputs = np.array([0.97, 0.71, 2.39, 0.97, 2.30, 2.39,
                            1.87, 2.40, 0.87, 2.15, 1.71, 1.54,
                            2.15, 2.17, 1.54, 2.20, 1.87, 1.0],
                        dtype=np.float)

salib_pb = {
    'num_vars': 2,
    'names': ['Test 1', 'Test 2'],
    'groups': None,
    'bounds': [[0.0, 1.0], [0.0, 1.0]]
}


name = "output"
print('*** Output: #{name}')
Si = ma.analyze(salib_pb, inputs, outputs, print_to_console=True)
fig, (ax1, ax2) = plt.subplots(1,2)
fig.suptitle('#{name} '+'sensitivity')
mp.horizontal_bar_plot(ax1, Si, {})
mp.covariance_plot(ax2, Si, {})

plt.show()
