#!/bin/bash --login
#
#PBS -l select=3
#PBS -q short
#PBS -l walltime=00:10:00
#PBS -A n02-cms
#PBS -N test_planet
#PBS -W umask=0022
#PBS -j oe
##PBS -m ae

export PBS_O_WORKDIR=$(readlink -f $PBS_O_WORKDIR)
cd $PBS_O_WORKDIR
export OMP_NUM_THREADS=1

echo hostname = $(hostname)

XIOS_BASE=$HOME/xios
XIOS_VERSION=trunk
XIOS_DIR=$XIOS_BASE/$XIOS_VERSION

#export PATH=$XIOS_BUILD_DIR/bin:$PATH

rm -f xios_server.exe
ln -s $XIOS_DIR/bin/xios_server.exe

aprun  -n 4 -N 4 planet.exe 0 2 : -n 4 -N 4 planet.exe 1 2 : -n 2 -N 2 xios_server.exe












