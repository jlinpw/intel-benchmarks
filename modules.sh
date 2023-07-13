#!/bin/bash

# find the correct modules
export intel_compilers=$(module avail 2>&1 | grep "intel-oneapi-compilers")
export intel_mpi=$(module avail 2>&1 | grep "intel-oneapi-mpi")

echo "Setting up environment and loading modules:"
echo $intel_compilers
echo $intel_mpi

module load $intel_compilers
module load $intel_mpi