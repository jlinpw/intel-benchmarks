#!/bin/bash

remote_node=${WFP_whost}
code_repo=https://github.com/jlinpw/intel-benchmarks
abs_path_to_code_repo="/home/${PW_USER}/$(basename $code_repo)"

# log into the cluster & clone the repository
ssh ${PW_USER}@${remote_node} << EOF
git clone ${code_repo}
git clone -c feature.manyFiles=true https://github.com/spack/spack.git
. $HOME/spack/share/spack/setup-env.sh
spack install intel-one-api-mpi intel-one-api-compilers
source/user/share/lmod/8.7.7/init/bash
spack module lmod refresh intel-one-api-mpi intel-oneapi-compilers
export MODULEPATH=$MODULEPATH:$HOME/spack/share/spack/lmod/linux-centos7-x86_64
EOF