program example_sgemm
  implicit none
  real(4), dimension(:,:), allocatable :: A, B, C, ref
  integer(8) :: devPtrA, devPtrB, devPtrC
  integer :: n=8, size_of_real=8
  integer :: i,j

  integer,dimension(8) :: values
  integer :: seed
  integer :: index
  
  
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

  !copy data to GPU
  call cublas_set_matrix(n,n,size_of_real,A,n,devPtrA,n)
  call cublas_set_matrix(n,n,size_of_real,B,n,devPtrB,n)
  call cublas_set_matrix(n,n,size_of_real,C,n,devPtrC,n)

  !call SGEMM from CUBLAS
  call cublas_sgemm('n','n',n,n,n,1.0,devPtrA,n,devPtrB,n,0.0,devPtrC,n)
    
  !copy data from GPU
  call cublas_get_matrix(n,n,size_of_real,devPtrC,n,C,n)

  !reference from CPU
  ref = matmul(A,B)

  index = 8
  !show result
  do j = 1, index
     do i = 1, index
        print*, ref(i,j), C(i,j)
     end do
  end do
  
  
  !Free GPU memory
  call cublas_free(devPtrA)
  call cublas_free(devPtrB)
  call cublas_free(devPtrC)
  
  
end program example_sgemm
