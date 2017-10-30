# AMBER Setup Scripts

This repository contains a set of scripts to perform basic maintenance operation on an installation of [AMBER](https://github.com/AA-ALERT/AMBER), a many-core accelerated and fully auto-tuned FRB pipeline.
The operations currently supported are:

- Install the pipeline
- Update the pipeline

# Users Guide

## Prerequisites

Before running this script it is necessary to set two environmental variables: `SOURCE_ROOT` and `INSTALL_ROOT`.
`SOURCE_ROOT` specifies where the source code of AMBER all its dependencies are saved; `INSTALL_ROOT` specifies where the libraries, includes, and executables are saved.
```
# Example
export SOURCE_ROOT=${HOME}/src/AMBER/src
export SOURCE_ROOT=${HOME}/src/AMBER/build
```
If the directories do not exist, they will be created by the script.

In order to compile and run, AMBER needs a working [OpenCL](https://www.khronos.org/opencl/) setup; OpenCL is a necessary dependency for the pipeline.

If the environmental variable `DEBUG` is set, generated executables and libraries will have compiler optimizations disabled, and contain all debug symbols.
If the environmental variable `OPENMP` is set, [OpenMP](http://www.openmp.org/) is used to parallelize some of the CPU workload.
```
# Example
export DEBUG=1
export OPENMP=1
```

There are also two optional dependencies: [PSRDADA](http://psrdada.sourceforge.net/) and [HDF5](https://support.hdfgroup.org/HDF5/).
To enable support for PSRDADA it is necessary to compile the package, and set the environmental variable `PSRDADA` to the directory containing the source code and object files.
PSRDADA support is necessary to read time series from a PSRDADA ringbuffer.
```
# Example
export PSRDADA=${HOME}/src/PSRDADA
```
To enable support for HDF5 it is necessary to install the C++ HDF5 libraries, then declare the environmental variable `LOFAR`; if HDF5 is not globally enable, it is also possible to set the environmental variable `HDF5INCLUDE` to the directory containing the include files, and the variable `HDF5DIR` to the directory containing the shared libraries.
HDF5 is used to support the file format used by LOFAR observations.
```
# Example
export LOFAR=1
export HDF5INCLUDE=${HOME}/src/hdf5/include
export HDF5DIR=${HOME}/src/hdf5/lib
```

## Install AMBER

To compile and install AMBER, run the `amber.sh` script.
The script takes two command line parameters; the first parameter is the mode, in this case `install`, and the second parameter is the development branch to use.
```
# Example
# Compile and install the master branch of AMBER
amber.sh install master
```

## Update AMBER

To update and recompile an already existing AMBER installation, run the `amber.sh` script and specify `update` as first parameter on the command line.
```
# Example
# Update and install the master branch of AMBER
amber.sh update master
```

