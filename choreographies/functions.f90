subroutine readgaussmeth(x,w,s,filename)
    
    real (kind = real_kind) , dimension(:)  , allocatable   , intent(out)   :: x,w
    integer                                                 , intent(out)   :: s
    character(len=*)                                        , intent(in)    :: filename
    
    integer , parameter                 :: iounit = 2       ! Number required by Fortran for Input/Output
    
!~     write(filename, '(A23,I3,A4,I2,A4)') "./output/gauss_int_meth", s,"prec",prec,".txt"
    
    open(unit = iounit, file = trim(filename))

    read(iounit,*) s    
    
    if (allocated(x)) then
        deallocate(x)
    end if
    
    if (allocated(w)) then
        deallocate(w)
    end if
    
    
    allocate(x(s))
    allocate(w(s))
    
    
    read(iounit,*) w
    read(iounit,*) x
    
    close(iounit)
    
end subroutine

subroutine readfouriercoeffs(nc,nb,nf,maxnf,abf,filename)   ! Reads Fourrier coefficients from file

    integer                                                         , intent(out)   :: nc       ! Number of cycles
    integer , dimension(:)  , allocatable                           , intent(out)   :: nb,nf    ! Number of bodies on cycles and of Fourier coeffs
    integer                                                         , intent(out)   :: maxnf    ! Max number of Fourier coefficients
    real(kind=real_kind)    , dimension(:,:,:,:)    , allocatable   , intent(out)   :: abf      ! Fourier coefficients
    character(len=*)                                                , intent(in)    :: filename 
    
    integer                             :: i
    logical                             :: readcoeffs
    integer , parameter                 :: iounit = 2       ! Number required by Fortran for Input/Output
    
    
    open(unit = iounit, file = trim(filename))

    read(iounit,*) nc

    if (allocated(nb)) then
        deallocate(nb)
    end if
    if (allocated(nf)) then
        deallocate(nf)
    end if
    
    allocate(nb(nc))
    allocate(nf(nc))

    read(iounit,*) nb
    read(iounit,*) nf
    read(iounit,*) readcoeffs
    
    maxnf = nf(1)
    do i=2,nc
        if (maxnf < nf(i)) then
            maxnf = nf(i)
        end if
    end do
    
    
    if (allocated(abf)) then
        deallocate(abf)
    end if
    
    if (readcoeffs) then
    
        allocate(   abf(nd,2,nc,maxnf)  )
        do i=1,nc
            read(iounit,*) abf(:,:,i,1:nf(i))
        end do
    
    end if

end subroutine

subroutine writefouriercoeffs(nc,nb,nf,maxnf,abf,filename)   ! Writes Fourrier coefficients to file

    integer                                                         , intent(in)    :: nc       ! Number of cycles
    integer , dimension(:)  , allocatable                           , intent(in)    :: nb,nf    ! Number of bodies on cycles and of Fourier coeffs
    integer                                                         , intent(in)    :: maxnf    ! Max number of Fourier coefficients
    real(kind=real_kind)    , dimension(:,:,:,:)    , allocatable   , intent(in)    :: abf      ! Fourier coefficients
    character(len=*)                                                , intent(in)    :: filename 
    
    integer                             :: i
    integer , parameter                 :: iounit = 2       ! Number required by Fortran for Input/Output
    
    
    open(unit = iounit, file = trim(filename))

    write(iounit,*) nc
    write(iounit,*) nb
    write(iounit,*) nf
    write(iounit,*) '.true.'
    do i=1,nc
        write(iounit,*) abf(:,:,i,1:nf(i))
    end do

end subroutine


! Subroutine to generate random seed based on clock timing
subroutine init_random_seed()

    integer :: ii, nn, clock
    integer, dimension(:), allocatable :: seed
    
    call random_seed(size = nn)
    allocate(seed(nn))
      
    call system_clock(count=clock)
      
    seed = clock + 37 * (/ (ii - 1, ii = 1, nn) /)
    call random_seed(put = seed)
      
    deallocate(seed)
end subroutine
