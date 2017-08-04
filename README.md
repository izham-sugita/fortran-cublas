# fortran-cublas
Using FORTRAN to call CUBLAS library's function.
NVIDIA CUDA SDK comes together with a fortran interfacing code in file fortran.c that can be compiled
together with your own fortran code to call cublas functions.

Files from NVIDIA CUDA 8.0 SDK
1. fortran.c
2. fortran.h
3. fortran_common.h

These three files must be compiled to produce the object file that will be compiled together with FORTRAN source code.
fortran.c can be compiled using either nvcc or gcc.
$gcc -I /where/is/your/cuda/include -c -DCUBLAS_GFORTRAN fortran.c -> will produce fortran.o
or
$nvcc -c -DCUBLAS_GFORTRAN fortran.c (you can add -I if you are not sure)

Your FORTRAN source code must be compiled together with fortran.o and link to CUBLAS library directory.
$gfortran -fno-second-underscore -L /where/your/cuda/lib64 source.f90 fortran.o -lcublas

The option -DCUBLAS_GFORTRAN can be found inside file fortran_common.h. You need to specify what type of FORTRAN compiler
that you want to use. The option -fno-second-underscore is required if you specified using gfortran (from -DCUBLAS_GFORTRAN).

The Makefile was written to automate the whole process. Details regarding available functions in CUBLAS library can be found at
http://docs.nvidia.com/cuda/cublas/index.html#using-the-cublas-api, which is an official CUDA documentation site. This repository 
was written to serve as a simple and direct guide to computational scientist that are still/love/have-to-use using FORTRAN.
Writing one's own CUDA kernel is not a trivial task, thus, utilizing available library is an option that must not be overlooked.
This is very true, especially for computational scientist because the science matters more than the programming.
