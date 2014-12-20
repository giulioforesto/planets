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

subroutine writeinitstate(iounit,t,mi,xi,nb)

    integer                                                     , intent(in)    :: iounit   ! Unit of I/O flux
    real (kind=real_kind)                                       , intent(in)    :: t        ! Current time
    real (kind=real_kind)   , allocatable   , dimension(:)      , intent(in)    :: mi       ! Mass of bodies
    real (kind=real_kind)   , allocatable   , dimension(:,:)    , intent(in)    :: xi       ! Position and velocity of bodies
    integer                                                     , intent(in)    :: nb       ! Number of bodies
    
    character (len=4)                                                           :: varnum
    integer                                                                     :: i,j

    write(iounit,'(A,E18.12)',advance='no') "{'t':",t
    write(iounit,'(A)',advance='no') ",'x':{"
    
    do i=1,nb-1
        write(varnum,'(I4.4)') i
        write(iounit,'(A,A,A)',advance='no') "'",varnum,"':["
        do j=1,nd-1
            write(iounit,'(E18.12,A)',advance='no')    xi(j,i),","
        end do
        write(iounit,'(E18.12,A)',advance='no')    xi(nd,i),"],"
    end do
    write(varnum,'(I4.4)') nb
    write(iounit,'(A,A,A)',advance='no') "'",varnum,"':["
    do j=1,nd-1
        write(iounit,'(E18.12,A)',advance='no')    xi(j,nb),","
    end do
    write(iounit,'(E18.12,A)',advance='no')    xi(nd,nb),"]},"

    write(iounit,'(A)',advance='no') "'m':{"
    do i=1,nb-1
        write(varnum,'(I4.4)') i
        write(iounit,'(A,A,A)',advance='no') "'",varnum,"':"
        write(iounit,'(E18.12,A)',advance='no')    mi(i),","
    end do
    write(varnum,'(I4.4)') nb
    write(iounit,'(A,A,A)',advance='no') "'",varnum,"':"
    write(iounit,'(E18.12,A)',advance='no')    mi(nb),"}"

    write(iounit,'(A)')    "},"

end subroutine


subroutine writecurrentstate_nomasschange(iounit,t,xi,nb)

    integer                                                     , intent(in)    :: iounit   ! Unit of I/O flux
    real (kind=real_kind)                                       , intent(in)    :: t        ! Current time
    real (kind=real_kind)   , allocatable   , dimension(:,:)    , intent(in)    :: xi       ! Position of bodies
    integer                                                     , intent(in)    :: nb       ! Number of bodies
    
    character (len=4)                                                           :: varnum
    integer                                                                     :: i,j


    write(iounit,'(A,E18.12)',advance='no') "{'t':",t
    write(iounit,'(A)',advance='no') ",'x':{"
    
    do i=1,nb-1
        write(varnum,'(I4.4)') i
        write(iounit,'(A,A,A)',advance='no') "'",varnum,"':["
        do j=1,nd-1
            write(iounit,'(E18.12,A)',advance='no')    xi(j,i),","
        end do
        write(iounit,'(E18.12,A)',advance='no')    xi(nd,i),"],"
    end do
    write(varnum,'(I4.4)') nb
    write(iounit,'(A,A,A)',advance='no') "'",varnum,"':["
    do j=1,nd-1
        write(iounit,'(E18.12,A)',advance='no')    xi(j,nb),","
    end do
    write(iounit,'(E18.12,A)',advance='no')    xi(nd,nb),"]}"
    
    write(iounit,'(A)')    "},"

end subroutine



subroutine print_cheat_traj(nc,nb,mc,nf,abf,ntours,npts,filename)
    integer                                                         , intent(in)    :: nc       ! Number of cycles
    real(kind=real_kind)    , dimension(:)    , allocatable         , intent(in)    :: mc       ! Mass of all bodies on a given cycle  
    integer , dimension(:)  , allocatable                           , intent(in)    :: nb,nf    ! Number of bodies on cycles and of Fourier coeffs
    real(kind=real_kind)    , dimension(:,:,:,:)    , allocatable   , intent(in)    :: abf      ! Fourier coefficients
    integer                                                         , intent(in)    :: ntours,npts    
    character(len=*)                                                , intent(in)    :: filename 

    integer             , parameter     :: iounit = 2       ! Number required by Fortran for Input/Output 
    
    real(kind=real_kind)    , dimension(:,:)    , allocatable   :: xi
    real(kind=real_kind)    , dimension(:)      , allocatable   :: mi

    integer                 ::  i,j,k,nbtot,nbi,n,pt
    real(kind=real_kind)    ::  t,dt
    
    dt = (2 * pi * ntours)/npts
    
    nbtot = nb(1)
    do i=2,nc
        nbtot = nbtot + nb(i)
    end do
    
    allocate(mi(nbtot))
    allocate(xi(nd,nbtot))
    
    nbi=0
    
    do i=1,nc
        do j=1,nb(i)
            nbi = nbi + 1
            mi(nbi) = mc(i)
            t = pi*(1 - ((j-1)*2.0_real_kind )/nb(i))
            xi(:,nbi)=0
            do k=0,nf(i)
                xi(:,nbi) = xi(:,nbi) + abf(:,1,i,k)*cos(k*t) + abf(:,2,i,k)*sin(k*t)
            end do
        end do
    end do
    
    open(unit = iounit, file = trim(filename), access='sequential', action='write',position='rewind')
    write(iounit,'(A)')    "["
    
    t=0
    
    call writeinitstate(iounit,t,mi,xi,nbtot)
    
    do pt=1,npts 
        nbi = 0   
        do i=1,nc
            do j=1,nb(i)
                nbi = nbi + 1
                t = pi + pt*dt - ((j-1)*2*pi)/nb(i)
                xi(:,nbi)=0
                do k=0,nf(i)
                    xi(:,nbi) = xi(:,nbi) + abf(:,1,i,k)*cos(k*t) + abf(:,2,i,k)*sin(k*t)
                end do
            end do
        end do
        
        t = pt*dt
        
        call writecurrentstate_nomasschange(iounit,t,xi,nbtot)
        
    end do
    
    write(iounit,'(A)')    "]"
    close(iounit)

end subroutine
