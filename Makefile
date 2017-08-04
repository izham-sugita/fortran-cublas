test-cublas-sgemm: test-sgemm.f90 fortran.o
	gfortran -L /usr/local/cuda-8.0/lib64 -o test-cublas-sgemm test-sgemm.f90 fortran.o -lcublas
fortran.o: fortran.c 
	gcc -DCUBLAS_GFORTRAN -I /usr/local/cuda-8.0/include -c fortran.c
clean:
	rm test-cublas-sgemm fortran.o
