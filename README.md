# Intel Benchmarks

Simple workflow to generate IMB-MPI1 alltoall and pingpong results for a medium instance Intel node, then graph them using plotly. It will generate `txt`, `csv`, and `html` files in the `results` folder in your job directory. 

## Usage
#### On the PW platform:
- [Add](https://docs.parallel.works/interacting-with-workflows/adding-workflows) a GitHub workflow and change `github.json` to the `github.json` from this repository. 
- Run the workflow as normal on the PW platform. The job status can be monitored under the workflow monitor. The job files and logs are under the newly created `/pw/jobs/<workflow-name>/<job-number>/` directory. 
- Wait for the workflow to run.
- When the workflow is finished running, the `.html` files within the job directory can be opened to visualize the plotly plots directly on the platform. 

#### General use:
This repository can also be cloned on any user container, then run with `python graph.py <processors>`, as long as the environment is setup and the required modules (`intel-oneapi-compiler` & `intel-oneapi-mpi`) are installed and loaded. 

#### Testing:
Run `python graph.py test <processors>` to use the test files from the repository.