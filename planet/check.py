
#module load python-compute pc-numpy pc-netcdf4-python

import numpy as np
from netCDF4 import Dataset
import glob
import operator
from collections import OrderedDict

class vgetter(object):
    def __init__(self, parent):
        self.parent = parent
    def __getitem__(self, name):
        vars = [ds.variables[name] for ds in self.parent.datasets]
        dims = vars[0].dimensions
        try:
            concat_dim = dims.index(u'y')
        except ValueError:
            # not a fancy dimensions
            return vars[0]
        
        return np.concatenate(vars, axis=concat_dim)
        
class TwoFile(object):
    def __init__(self, basename):
        self.filenames = [basename+'_0.nc', basename+'_1.nc']
        self.datasets = [Dataset(fn) for fn in self.filenames]
        self.variables = vgetter(self)
    
    # def variable(self, name):
    #     vars = [ds.variables[name] for ds in self.datasets]
    #     dims = vars[0].dimensions
    #     try:
    #         concat_dim = dims.index(u'y')
    #     except ValueError:
    #         # not a fancy dimensions
    #         return vars[0]
        
    #     return np.concatenate(vars, axis=concat_dim)

        
FORTRAN ="""
  INTEGER,PARAMETER :: ni_glo=100
  INTEGER,PARAMETER :: nj_glo=100
  INTEGER,PARAMETER :: llm=5
  DOUBLE PRECISION :: field_A_glo(ni_glo,nj_glo,llm)

  DO j=1,nj_glo
    DO i=1,ni_glo
      lon_glo(i,j)=(i-1)+(j-1)*ni_glo
      lat_glo(i,j)=1000+(i-1)+(j-1)*ni_glo
      DO l=1,llm
        field_A_glo(i,j,l)=(i-1)+(j-1)*ni_glo+10000*l + ensemble_index
      ENDDO
    ENDDO
  ENDDO"""
    
ni_glo=100
nj_glo=100
llm=5
ensemble_index = 0

lon_glo = np.zeros((nj_glo, ni_glo), dtype=np.float32)
lat_glo = np.zeros((nj_glo, ni_glo), dtype=np.float32)
field_A_glo = np.zeros((llm, nj_glo, ni_glo), dtype=np.float32)

for j in xrange(nj_glo):
    for i in xrange(ni_glo):
        lon_glo[j, i] = i + j * ni_glo
        lat_glo[j, i] = 1000 + i + j*ni_glo
        for l in xrange(llm):
            field_A_glo[l, j, i] = i + ni_glo*(j + nj_glo*(l+1)) + ensemble_index

time_idx = 0

data = TwoFile('output')
lon = data.variables['nav_lon']
lat = data.variables['nav_lat']
fa_min = data.variables['min'][time_idx]
fa_mean = data.variables['mean'][time_idx]
fa_max = data.variables['max'][time_idx]

print "lat match?", np.all(lat_glo == lat)
print "lon match?", np.all(lon_glo == lon)

print "min(field_A) match?", np.all(fa_min == field_A_glo)
print "mean(field_A) match?", np.all(fa_mean == (field_A_glo+0.5))
print "max(field_A) match?", np.all(fa_max == field_A_glo+1)

