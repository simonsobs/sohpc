# Simons Observatory HPC Installation

This repo contains scripts for installing Simons Observatory tools from source
on clusters / HPC systems.  These scripts rely on a base installation of the
`cmbenv` software stack (https://github.com/hpc4cmb/cmbenv).  Before building these
packages, first load that environment.

If you are installing Simons Observatory tools on a laptop or workstation, and are
not developing the `so3g` package or its dependencies, then it is likely easier to
create a python virtualenv and use pip to install everything.

If you just want to **use** already installed versions of this software (for
example at NERSC or another center), then see the Simons Observatory wiki page
for that system.

The rest of this document describes how to build the software stack from source if
you are maintaining that installation.

## Docker Containers

Each tag of this repo builds a docker container which can be found here.  **FIXME: currently hosted under hpc4cmb, not simonsobs**.

| MPI Variant |       Container                                                  |
|-------------|------------------------------------------------------------------|
| MPICH       | https://hub.docker.com/repository/docker/simonsobs/sohpc-mpich   |
| OpenMPI     | https://hub.docker.com/repository/docker/simonsobs/sohpc-openmpi |

There are containers built with both MPICH and OpenMPI.  You should use the one
which is compatible with the MPI version on your system.  Most HPC centers that
support container solutions will inject / mount the system libraries (including
MPI) into user containers when they are launched.  This makes it critical to
use a container that includes an ABI-compatible MPI implementation.  For example,
on the Cray systems at NERSC, you should use the MPICH flavor of the container when
using the `shifter` container solution.

## Generate the Install Script

Select (or create) a system config file in the `configs` directory.  Next, select where
you want to install all the packages and "version" to assign this overall installation
(for example the current date).  Now generate the install script:

```bash
./sohpc_setup.sh \
-c linux \
-p ${HOME}/simonsobs \
-v $(date +%Y%m%d)
```

This will produce a script called `install_linux.sh` (or whatever the name of the config
you used in the configs directory).  Make a build directory and run it from there:

```bash
mkdir build
cd build
../install_linux.sh | tee log
```

## Loading the Software

Now you can load the environment with either a shell init file:
```bash
source ${HOME}/simonsobs/sohpc_init.sh
```
OR with modules
```bash
module use ${HOME}/simonsobs/modulefiles
module load sohpc
source sohpc
```

## Installing a Jupyter Kernel

After you have loaded the environment, you can install a jupyter kernel with:
```bash
sohpc-jupyter
```
