# Simons Observatory HPC Installation

This repo contains scripts for installing Simons Observatory tools from source
on clusters / HPC systems.  These scripts rely on a base installation of the
`cmbenv` software stack (https://github.com/hpc4cmb/cmbenv).  Before building these
packages, first load that environment.

If you are just installing Simons Observatory tools on a laptop or workstation,
it is probably easier to create a python virtualenv and use pip to install
everything.

## Docker Containers

Each tag of this repo builds a docker container which can be found here:


There are containers built with both MPICH and OpenMPI.  You should use the one
which is compatible with the MPI version on your system.  Most HPC centers that
support container solutions will inject / mount the system libraries (including
MPI) into user containers when they are launched.  This makes it critical to
use a container that includes an ABI compatible MPI implementation.


## Generate the Install Script

Select (or create) an system config file in the `configs` directory.  Next, select where
you want to install all the packages and "version" to assign this overall installation
(for example the current date).  Now generate the install script:

```bash
./so_generate.sh \
-c linux \
-p ${HOME}/simons_obs \
-v $(date +%Y%m%d)
```

This will produce a script called `install_linux.sh` (or whatever the name of the config
you used in the configs directory).  Make a build directory and run it from there:

```bash
mkdir build
cd build
../install_linux.sh
```

## Loading the Software

Now you can load the environment with either a shell init file:
```bash
source ${HOME}/simons_obs/so_env_init.sh
```
OR with modules
```bash
module use ${HOME}/simons_obs/modulefiles
module load sohpc
```

And finally, source the activation script:
```bash
source sohpc
```

## Installing a Jupyter Kernel

After you have loaded the environment, you can install a jupyter kernel with:
```bash
sohpc-jupyter
```
