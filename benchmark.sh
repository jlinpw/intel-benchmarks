#!/bin/bash

# Load  workflow parameter names and values from the XML as environment variables
# In this case: processors, resource_1_username, resource_1_publicIp
source inputs.sh

# save the job number & job directory
export job_number=$(basename ${PWD})
export job_dir=$(pwd | rev | cut -d'/' -f1-2 | rev)
export remote_node=${resource_1_publicIp}

# get the correct repo & paths
export code_repo=https://github.com/parallelworks/intel-benchmarks
export abs_path_to_code_repo="/home/${PW_USER}/pw/workflows/$(basename $code_repo)"
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
echo "REMOTE NODE:  ${remote_node}"
echo "USER:         ${PW_USER}"
echo

# set up spack & mpi
ssh ${remote_node} 'bash -s' < setup.sh

# env setup just in case
# source /etc/profile.d/lmod.sh
# source /home/ubuntu/spack/share/spack/setup-env.sh
# #export MODULEPATH=$MODULEPATH:/home/ubuntu/spack/share/spack/lmod/linux-ubuntu22.04-x86_64/Core
# module use /home/ubuntu/spack/share/spack/lmod/linux-ubuntu22.04-x86_64/Core

# install dependencies
#export requirements="${abs_path_to_code_repo}/requirements.txt"
export requirements="${job_dir}/requirements.txt"
ssh ${remote_node} "pip install --upgrade pip"
ssh ${remote_node} "pip install -r $requirements"

# load the modules
# module load intel-oneapi-compilers/2023.1.0-u3hp4we intel-oneapi-mpi/2021.9.0-hnwuxap

# set up env & load the modules - must be done at once so the correct modules are loaded
ssh ${remote_node} << EOF
. $HOME/spack/share/spack/setup-env.sh
source /usr/share/lmod/8.7.7/init/bash
export MODULEPATH=$MODULEPATH:$HOME/spack/share/spack/lmod/linux-centos7-x86_64

module avail

source ${abs_path_to_code_repo}/modules.sh
module list

# run the benchmark tests and pipe the output into a file
echo "Running alltoall..."
mpirun -np ${processors} IMB-MPI1 alltoall > alltoall.txt &
pid=$!
wait $pid
echo "Alltoall completed!"
echo

echo "Running pingpong..."
mpirun -np ${processors} IMB-MPI1 pingpong > pingpong.txt &
pid2=$!
wait $pid2
echo "Pingpong completed!"
echo
EOF

# make the graph
echo "Creating graphs..."
ssh ${remote_node} "python3 ${abs_path_to_code_repo}/graph.py ${processors}"

# copy the files back to the job directory if the env variables exist
if [[ ! -z $job_number ]];then
    echo "Copying results back to job directory..."
    echo JOBNUM: $job_number
    echo JOBDIR: ${PWD}
    mkdir ${PWD}/results
    
    #     cat << EOF > service.html
    # <body style="background:white;">
    # <img style="width:40%;display:inline-block;position:relative" src="/me/3001/api/v1/display/$HOME/pw/jobs/$job_dir/results/alltoall.html">
    # <img style="width:40%;display:inline-block;position:relative" src="/me/3001/api/v1/display/$HOME/pw/jobs/$job_dir/results/pingpong.html">
    # </body>
    # EOF
    
    # scp *.csv *.txt *.html $HOME/pw/jobs:$job_dir/results && ./clean.sh
    scp ${remote_node}:*.csv ${remote_node}:*.txt ${remote_node}:*.html ${PWD}/results && ./clean.sh
    # scp remote_username@remote_host:/remote/file.txt local_directory/
    
fi

