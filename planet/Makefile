XIOS_BASE=$(HOME)/xios
XIOS_VERSION=trunk
XIOS_DIR = $(XIOS_BASE)/$(XIOS_VERSION)

NAME = planet

FC = ftn
FFLAGS = -I$(XIOS_DIR)/inc -D__NONE__ -O0 -g -traceback -I /opt/cray/netcdf-hdf5parallel/4.4.1.1/INTEL/15.0/include -warn

$(NAME).exe : $(NAME).o
	$(FC) -nofor-main -o $@ $^ -L$(XIOS_DIR)/lib -lxios -Wl,"--allow-multiple-definition" -Wl,"-Bstatic" -L /opt/cray/netcdf-hdf5parallel/4.4.1.1/INTEL/15.0/lib -L /opt/cray/netcdf-hdf5parallel/4.4.1.1/INTEL/15.0/lib  -lnetcdf -lnetcdff -lhdf5_hl -lhdf5 -lz -lstdc++

$(NAME).o : $(NAME).f90
	$(FC) -o $@ $(FFLAGS) -c $<


.PHONY: clean
clean :
	-rm $(NAME).o $(NAME).exe
