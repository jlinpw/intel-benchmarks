#!/bin/bash

code_repo=https://github.com/jlinpw/intel-benchmarks
# abs_path_to_code_repo="/home/${PW_USER}/$(basename $code_repo)"
# intel_compilers=$(module avail 2>&1 | grep -o "Core/intel-oneapi-compilers/[^[:space:]]*")
# intel_mpi=$(module avail 2>&1 | grep -o "Core/intel-oneapi-mpi/[^[:space:]]*")

# clone the repository, download spack, setup modules
git clone ${code_repo}
git clone -c feature.manyFiles=true https://github.com/spack/spack.git
. $HOME/spack/share/spack/setup-env.sh
spack install intel-oneapi-mpi intel-oneapi-compilers
source /usr/share/lmod/8.7.7/init/bash
yes | spack module lmod refresh intel-oneapi-mpi intel-oneapi-compilers