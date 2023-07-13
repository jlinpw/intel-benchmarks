#!/bin/bash

# find the correct modules
export intel_compilers=$(module avail 2>&1 | grep "intel-oneapi-compilers")

echo "Setting up environment and loading modules:"
echo $(module avail 2>&1 | grep "intel-oneapi-compilers")
echo $intel_compilers

module load $intel_compilers