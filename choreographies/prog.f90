! Sets the number of threads to be created by OpenMP

!$ call omp_set_num_threads(numthreads)

! Calls random seed initialization

call init_random_seed()

! Reads integration method from file

call readgaussmeth(xi,wi,si,gaussmethfilename)

! Reads initial Fourrier coefficients

call readfouriercoeffs(nc,mc,nb,maxnb,nf,maxnf,abf,fourrierimportcoefffilename)

! If data was not available, we start from a random initial state

if (.not. (allocated(abf))) then
    
    allocate(   abf(nd,2,nc,0:maxnf)  )
    
    do i=1,nd
        do j=1,2
            do k=1,nc
                do l=0,min(nf(k),maxnfinit)
                    
                    call random_number(nran)
                    abf(i,j,k,l) = nran
                    
                end do
            end do
        end do
    end do

end if

allocate(sincostable(2,si,nc,maxnb,0:maxnf))
call evaltrig(xi,si,nc,nb,nf,maxnf,sincostable)

print*,si
print*,nc
print*,nb
print*,mc

act = 0

abf = 0
abf(1,1,1,1) = 1
abf(2,2,1,1) = 1

call evalaction(nd,si,wi,nc,nb,maxnb,mc,nf,maxnf,sincostable,abf,act)
print*, abf

print*, '---'

print*,act



call print_init_state(nc,nb,mc,nf,abf,exportinitstatefilename)
