#!/bin/bash

# Load  workflow parameter names and values from the XML as environment variables
# In this case: processors, resource_1_username, resource_1_publicIp
source inputs.sh

# save the job number & job directory
export job_number=$(basename ${PWD})
export job_dir=$(pwd | rev | cut -d'/' -f1-2 | rev)
export remote_node=${resource_1_publicIp}

# get the correct repo & paths
export code_repo=https://github.com/jlinpw/intel-benchmarks
export abs_path_to_code_repo="/home/${PW_USER}/$(basename $code_repo)"
echo "export job_number=${job_number}" >> inputs.sh

# export the users env file
while read LINE; do export "$LINE"; done < ~/.env

# echo some useful information
echo
echo "JOB NUMBER:  ${job_number}"
echo "USER:        ${PW_USER}"
echo "DATE:        $(date)"
echo "DIRECTORY:   ${PWD}"
echo "COMMAND:     $0"
echo

# set up spack & mpi
./setup.sh

# env setup just in case
# source /etc/profile.d/lmod.sh
# source /home/ubuntu/spack/share/spack/setup-env.sh
# #export MODULEPATH=$MODULEPATH:/home/ubuntu/spack/share/spack/lmod/linux-ubuntu22.04-x86_64/Core
# module use /home/ubuntu/spack/share/spack/lmod/linux-ubuntu22.04-x86_64/Core

# install dependencies
# sudo yum update python3
export requirements="${abs_path_to_code_repo}/requirements.txt"
ssh ${PW_USER}@${remote_node} "pip install --upgrade pip"
ssh ${PW_USER}@${remote_node} "pip install -r $requirements"

# load the modules
# module load intel-oneapi-compilers/2023.1.0-u3hp4we intel-oneapi-mpi/2021.9.0-hnwuxap

# set up env & load the modules
ssh ${PW_USER}@${remote_node} << EOF
. $HOME/spack/share/spack/setup-env.sh
source /usr/share/lmod/8.7.7/init/bash
export MODULEPATH=$MODULEPATH:$HOME/spack/share/spack/lmod/linux-centos7-x86_64

module avail

# find the correct modules
# export intel_compilers=$(module avail 2>&1 | grep "intel-oneapi-compilers")

# echo "Setting up environment and loading modules:"
# echo $(module avail 2>&1 | grep "intel-oneapi-mpi")
# echo $intel_compilers

# module load $intel_compilers
source ${abs_path_to_code_repo}/modules.sh
module list

# run the benchmark test and pipe the output into a file
echo "Running alltoall:"
mpirun -np ${processors} IMB-MPI1 alltoall > alltoall.txt
echo "Running pingpong:"
mpirun -np ${processors} IMB-MPI1 pingpong > pingpong.txt
EOF

# make the graph
ssh ${PW_USER}@${remote_node} "python3 ${abs_path_to_code_repo}/graph.py ${processors}"

# copy the files back to the job directory if the env variables exist
if [[ ! -z $jobnum ]];then
    echo JOBNUM: $jobnum
    echo JOBDIR: $jobdir
    ssh usercontainer mkdir $jobdir/results
    
    cat << EOF > service.html
<body style="background:white;">
<img style="width:40%;display:inline-block;position:relative" src="/me/3001/api/v1/display$jobdir/results/alltoall.html">
<img style="width:40%;display:inline-block;position:relative" src="/me/3001/api/v1/display$jobdir/results/pingpong.html">
</body>
EOF
    
    scp *.csv *.txt *.png service.html usercontainer:$jobdir/results && ./clean.sh
    
fi

