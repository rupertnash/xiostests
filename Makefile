XIOS_DIR = /home/n02/n02/rnashn02/xios/ensemble


FC = ftn
FFLAGS = -I$(XIOS_DIR)/inc -D__NONE__ -O0 -g -traceback -I /opt/cray/netcdf-hdf5parallel/4.4.1.1/INTEL/15.0/include

cube.exe : cube.o
	$(FC) -nofor-main -o $@ $^ -L$(XIOS_DIR)/lib -lxios -Wl,"--allow-multiple-definition" -Wl,"-Bstatic" -L /opt/cray/netcdf-hdf5parallel/4.4.1.1/INTEL/15.0/lib -L /opt/cray/netcdf-hdf5parallel/4.4.1.1/INTEL/15.0/lib  -lnetcdf -lnetcdff -lhdf5_hl -lhdf5 -lz -lstdc++

cube.o : cube.f90
	$(FC) -o $@ $(FFLAGS) -c $<


