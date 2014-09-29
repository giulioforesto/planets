! Sets the number of threads to be created by OpenMP

!$ call omp_set_num_threads(numthreads)

! Calls random seed initialization

call init_random_seed()

! Reads integration method from file

call readgaussmeth(xi,wi,si,gaussmethfilename)

! Reads initial Fourrier coefficients

call readfouriercoeffs(nc,nb,nf,maxnf,abf,fourrierimportcoefffilename)

! If data was not available, we start from a random initial state

if (.not. (allocated(abf))) then
    
    allocate(   abf(nd,2,nc,maxnf)  )
    
    do i=1,nd
        do j=1,2
            do k=1,nc
                do l=1,nf(k)
                    
                    call random_number(nran)
                    abf(i,j,k,l) = nran
                    
                end do
            end do
        end do
    end do

end if



