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

subroutine readfouriercoeffs(nc,mc,nb,maxnb,nf,maxnf,abf,filename)   ! Reads masses and Fourrier coefficients from file

    integer                                                         , intent(out)   :: nc       ! Number of cycles
    real(kind=real_kind)    , dimension(:)    , allocatable         , intent(out)   :: mc       ! Mass of all bodies on a given cycle 
    integer , dimension(:)  , allocatable                           , intent(out)   :: nb,nf    ! Number of bodies on cycles and of Fourier coeffs
    integer                                                         , intent(out)   :: maxnb,maxnf  ! Max number of bodies on cycles and Fourier coefficients
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
    if (allocated(mc)) then
        deallocate(mc)
    end if
    if (allocated(nf)) then
        deallocate(nf)
    end if
    
    allocate(nb(nc))
    allocate(mc(nc))
    allocate(nf(nc))

    read(iounit,*) nb
    read(iounit,*) mc
    read(iounit,*) nf
    read(iounit,*) readcoeffs
    
    maxnf = nf(1)
    do i=2,nc
        if (maxnf < nf(i)) then
            maxnf = nf(i)
        end if
    end do

    maxnb = nb(1)
    do i=2,nc
        if (maxnb < nb(i)) then
            maxnb = nb(i)
        end if
    end do
    
    
    if (allocated(abf)) then
        deallocate(abf)
    end if
    
    if (readcoeffs) then
    
        allocate(   abf(nd,2,nc,0:maxnf)  )
        do i=1,nc
            read(iounit,*) abf(:,:,i,0:nf(i))
        end do
    
    end if

    close(iounit)

end subroutine

subroutine writefouriercoeffs(nc,mc,nb,nf,maxnf,abf,filename)   ! Writes masses and Fourrier coefficients to file

    integer                                                         , intent(in)    :: nc       ! Number of cycles
    real(kind=real_kind)    , dimension(:)    , allocatable         , intent(in)    :: mc       ! Mass of all bodies on a given cycle  
    integer , dimension(:)  , allocatable                           , intent(in)    :: nb,nf    ! Number of bodies on cycles and of Fourier coeffs
    integer                                                         , intent(in)    :: maxnf    ! Max number of Fourier coefficients
    real(kind=real_kind)    , dimension(:,:,:,:)    , allocatable   , intent(in)    :: abf      ! Fourier coefficients
    character(len=*)                                                , intent(in)    :: filename 
    
    integer                             :: i
    integer , parameter                 :: iounit = 2       ! Number required by Fortran for Input/Output
    
    
    open(unit = iounit, file = trim(filename))

    write(iounit,*) nc
    write(iounit,*) nb
    write(iounit,*) mc
    write(iounit,*) nf
    write(iounit,*) '.true.'
    do i=1,nc
        write(iounit,*) abf(:,:,i,1:nf(i))
    end do
    
    close(iounit)

end subroutine

subroutine print_init_state(nc,nb,mc,nf,abf,filename)
    integer                                                         , intent(in)    :: nc       ! Number of cycles
    real(kind=real_kind)    , dimension(:)    , allocatable         , intent(in)    :: mc       ! Mass of all bodies on a given cycle  
    integer , dimension(:)  , allocatable                           , intent(in)    :: nb,nf    ! Number of bodies on cycles and of Fourier coeffs
    real(kind=real_kind)    , dimension(:,:,:,:)    , allocatable   , intent(in)    :: abf      ! Fourier coefficients
    character(len=*)                                                , intent(in)    :: filename 

    integer                             :: i,j,k,nbtot,d
    real(kind=real_kind)                :: t,x,v
    
    integer             , parameter     :: iounit = 2       ! Number required by Fortran for Input/Output 
    character(len=*)    , parameter     :: ioform = '(e42.33E3)'

           
    open(unit = iounit, file = trim(filename))

    nbtot = nb(1)
    do i=2,nc
        nbtot = nbtot + nb(i)
    end do

    write(iounit,*) nbtot
    
    do i=1,nc
        do j=1,nb(i)
            write(iounit,ioform,advance='no') mc(i)       
        end do
    end do
    write(iounit,*) ' '

    do d=1,nd
        do i=1,nc
            do j=1,nb(i)
                t = pi*(1 - ((j-1)*2.0_real_kind )/nb(i))
                x=0
                do k=0,nf(i)
                    x = x + abf(d,1,i,k)*cos(k*t) + abf(d,2,i,k)*sin(k*t)
                end do
                write(iounit,ioform,advance='no') x
            end do
        end do
        write(iounit,*) ' '
    end do
    
    do d=1,nd
        do i=1,nc
            do j=1,nb(i)
                t = pi*(1 - ((j-1)*2.0_real_kind )/nb(i))
                v = 0
                do k=1,nf(i)
                    v = v - k*abf(d,1,i,k)*sin(k*t) + k*abf(d,2,i,k)*cos(k*t)
                end do
                write(iounit,ioform,advance='no') v
            end do
        end do
        write(iounit,*) ' '
    end do


    close(iounit)
end subroutine


