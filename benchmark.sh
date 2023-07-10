#!/bin/bash

# env setup just in case
source /etc/profile.d/lmod.sh
source /home/ubuntu/spack/share/spack/setup-env.sh
#export MODULEPATH=$MODULEPATH:/home/ubuntu/spack/share/spack/lmod/linux-ubuntu22.04-x86_64/Core
module use /home/ubuntu/spack/share/spack/lmod/linux-ubuntu22.04-x86_64/Core
# install dependencies
pip install -r requirements.txt

# load the modules
module load intel-oneapi-compilers/2023.1.0-u3hp4we intel-oneapi-mpi/2021.9.0-hnwuxap

# run the benchmark test and pipe the output into a file
mpirun -np 16 IMB-MPI1 alltoall > alltoall.txt
mpirun -np 16 IMB-MPI1 pingpong > pingpong.txt

# go to home
cd

# make the graph
python graph.py

# copy the files back to the job directory if the env variables exist
if [[ ! -z $jobnum ]];then
    echo JOBNUM: $jobnum
    echo JOBDIR: $jobdir
    ssh usercontainer mkdir $jobdir/results
    
    cat << EOF > service.html
<body style="background:white;">
<img style="width:40%;display:inline-block;position:relative" src="/me/3001/api/v1/display$jobdir/results/alltoall.png">
<img style="width:40%;display:inline-block;position:relative" src="/me/3001/api/v1/display$jobdir/results/pingpong.png">
</body>
EOF
    
    scp *.csv *.txt *.png service.html usercontainer:$jobdir/results && ./clean.sh
    
fi

