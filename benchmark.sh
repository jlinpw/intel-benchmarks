#!/bin/bash

# Load  workflow parameter names and values from the XML as environment variables
# In this case: processors, resource_1_username, resource_1_publicIp
source inputs.sh

export job_number=$(basename ${PWD})
export job_dir=$(pwd | rev | cut -d'/' -f1-2 | rev)
echo "export job_number=${job_number}" >> inputs.sh

# export the users env file (for some reason not all systems are getting these upon execution)
while read LINE; do export "$LINE"; done < ~/.env

echo
echo "JOB NUMBER:  ${job_number}"
echo "USER:        ${PW_USER}"
echo "DATE:        $(date)"
echo "DIRECTORY:   ${PWD}"
echo "COMMAND:     $0"
# Very useful to rerun a workflow with the exact same code version!
#commit_hash=$(git --git-dir=clone/.git log --pretty=format:'%h' -n 1)
#echo "COMMIT HASH: ${commit_hash}"
echo

# env setup just in case
source /etc/profile.d/lmod.sh
source /home/ubuntu/spack/share/spack/setup-env.sh
#export MODULEPATH=$MODULEPATH:/home/ubuntu/spack/share/spack/lmod/linux-ubuntu22.04-x86_64/Core
module use /home/ubuntu/spack/share/spack/lmod/linux-ubuntu22.04-x86_64/Core

# install dependencies
yum update python3
pip install --upgrade pip
pip install -r requirements.txt

# load the modules
module load intel-oneapi-compilers/2023.1.0-u3hp4we intel-oneapi-mpi/2021.9.0-hnwuxap

# run the benchmark test and pipe the output into a file
mpirun -np ${processors} IMB-MPI1 alltoall > alltoall.txt
mpirun -np ${processors} IMB-MPI1 pingpong > pingpong.txt

# make the graph
python3 ${PWD}/graph.py ${processors}

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

