#!/bin/bash --login
#
#PBS -l select=2
#PBS -q short
#PBS -l walltime=00:10:00
#PBS -A n02-cms
#PBS -N test_cube
#PBS -W umask=0022
#PBS -j oe

export PBS_O_WORKDIR=$(readlink -f $PBS_O_WORKDIR)
cd $PBS_O_WORKDIR

export OMP_NUM_THREADS=1

XIOS_BUILD_DIR=/home/n02/n02/rnashn02/xios/trunk
export PATH=$XIOS_BUILD_DIR/bin:$PATH

rm -f xios_server.exe
ln -s $XIOS_BUILD_DIR/bin/xios_server.exe

aprun  -n 8 -N 8 ./cube.exe  : -n 2 -N 2 ./xios_server.exe












