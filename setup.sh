#!/bin/bash

source inputs.sh

remote_node=${resource_1_publicIp}
code_repo=https://github.com/jlinpw/intel-benchmarks
abs_path_to_code_repo="/home/${PW_USER}/$(basename $code_repo)"

echo "REMOTE NODE:  ${remote_node}"
echo "USER:         ${PW_USER}"
echo

# log into the cluster & clone the repository
ssh ${PW_USER}@${remote_node} << EOF
git clone ${code_repo}
git clone -c feature.manyFiles=true https://github.com/spack/spack.git
. $HOME/spack/share/spack/setup-env.sh
spack install intel-oneapi-mpi intel-oneapi-compilers
source /usr/share/lmod/8.7.7/init/bash
yes | spack module lmod refresh intel-oneapi-mpi intel-oneapi-compilers
module avail
export MODULEPATH=$MODULEPATH:$HOME/spack/share/spack/lmod/linux-centos7-x86_64
EOF