#!/bin/bash

code_repo=https://github.com/jlinpw/intel-benchmarks

# clone the repository, download spack, setup modules
git clone ${code_repo}
git clone -c feature.manyFiles=true https://github.com/spack/spack.git
. $HOME/spack/share/spack/setup-env.sh
spack install intel-oneapi-mpi intel-oneapi-compilers gcc-runtime
source /usr/share/lmod/8.7.7/init/bash
yes | spack module lmod refresh gcc-runtime intel-oneapi-mpi intel-oneapi-compilers
