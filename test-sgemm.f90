program example_sgemm
  implicit none
  real(4), dimension(:,:), allocatable :: A, B, C, ref
  real(8) :: tstart, tstop, elapsed_time
  real(8) :: gflops, sum, L2
  integer(8) :: devPtrA, devPtrB, devPtrC
  integer :: n=2048
  integer :: size_of_real=4 !4->single precision; 8->double precision
  integer :: i,j

  integer,dimension(8) :: values
  integer :: seed
  integer :: index

  real(8),parameter :: pi = 4.0*atan(1.0)
  
  allocate(A(n,n))
  allocate(B(n,n))
  allocate(C(n,n))
  allocate(ref(n,n))

  call cublas_alloc(n*n, size_of_real, devPtrA)
  call cublas_alloc(n*n, size_of_real, devPtrB)
  call cublas_alloc(n*n, size_of_real, devPtrC)

  call date_and_time(VALUES=values) !values(8) = milisecs of the second
  seed = values(8) !using value in milisecs as seeder
  call srand(seed) !not a std implementation, but i like it better.

  !initiating matrix value
  do j = 1, n
     do i = 1, n
        A(i,j) = rand()
        B(i,j) = rand()
     end do
  end do

  !solution matrix
  C = 0.0
  !reference matrix
  ref = 0.0

!  call cpu_time(tstart)
  !copy data to GPU
  call cublas_set_matrix(n,n,size_of_real,A,n,devPtrA,n)
  call cublas_set_matrix(n,n,size_of_real,B,n,devPtrB,n)
  call cublas_set_matrix(n,n,size_of_real,C,n,devPtrC,n)

  call cpu_time(tstart)
  !call SGEMM from CUBLAS
  call cublas_sgemm('n','n',n,n,n,1.0,devPtrA,n,devPtrB,n,0.0,devPtrC,n)
  
  !copy data from GPU
  call cublas_get_matrix(n,n,size_of_real,devPtrC,n,C,n)
  call cpu_time(tstop)

  elapsed_time = tstop - tstart !in seconds

  write(*,*) 'Matrix A ', n,'x',n
  write(*,*) 'Matrix B ', n,'x',n
  write(*,20) 'Elapsed time : ',elapsed_time, 'secs'
 
  gflops = 2*float(n)*float(n)*float(n)/(elapsed_time*1.0e9)
  write(*,10)  'Performance:', gflops,' GFLOPS'
  
10 format(A12,2X,1F10.4,2X,A7)
20 format(A15,2X,1F12.8,2X,A4)  
  
  !reference from CPU
  ref = matmul(A,B)

  index = n
  sum = 0.0
  !show result
  do j = 1, index
     do i = 1, index
        sum = sum + ( ref(i,j)- C(i,j) )*( ref(i,j)- C(i,j) )
     end do
  end do
  L2 = sqrt( sum / ( float(index)*float(index) ) )
  write(*,30) 'L2-residual :', L2
30 format(A15,2X,1E18.8)
  
  !Free GPU memory
  call cublas_free(devPtrA)
  call cublas_free(devPtrB)
  call cublas_free(devPtrC)
  
  
end program example_sgemm
