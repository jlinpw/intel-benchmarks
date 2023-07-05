#!/bin/bash

# load the modules
module load intel-oneapi-compilers/2023.1.0-u3hp4we intel-oneapi-mpi/2021.9.0-hnwuxap

# run the benchmark test and pipe the output into a file
mpirun -np 16 IMB-MPI1 alltoall > alltoall.txt
mpirun -np 16 IMB-MPI1 pingpong > pingpong.txt

# make the graph
python graph-two.py