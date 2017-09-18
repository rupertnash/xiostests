
#module load python-compute pc-numpy pc-netcdf4-python

import numpy as np
from netCDF4 import Dataset
import glob

class TwoFile(object):
    def __init__(self, basename):
        self.filenames = [basename+'_0.nc', basename+'_1.nc']
        self.datasets = [Dataset(fn) for fn in self.filenames]
        
    def variable(self, name):
        vars = [ds.variables[name] for ds in self.datasets]
        dims = vars[0].dimensions
        try:
            concat_dim = dims.index(u'lat')
        except ValueError:
            # not a fancy dimensions
            return vars[0]
        
        return np.concatenate(vars, axis=concat_dim)

data = TwoFile('cube')
# first time index only...
temp = data.variable('temp')[0]

# Recall axes are ordered time, z, lat lon
x = 3600*np.arange(60)[np.newaxis, np.newaxis, :]
y = 60*np.arange(60)[np.newaxis, :, np.newaxis]
z = np.arange(60)[:, np.newaxis, np.newaxis]
comp = x+y+z

assert np.all(comp==temp)

print "basic output OK"

zmin_file = data.variable('zmin')[0]
zmin_comp = comp.min(axis=0)
