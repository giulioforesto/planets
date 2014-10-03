subroutine readbutchertable(filename,a,b,c,s)
    
    character(len=*)                                            , intent(in)   :: filename
    real(kind=real_kind)    , allocatable   , dimension(:,:)    , intent(out)  :: a
    real(kind=real_kind)    , allocatable   , dimension(:)      , intent(out)  :: b,c
    integer                                                     , intent(out)  :: s

    integer , parameter                 :: iounit = 2           ! Number required by Frotran for Input/Output
    integer                             :: i
    
    if (allocated(a)) then
        deallocate(a)
    end if
    if (allocated(b)) then
        deallocate(b)
    end if
    if (allocated(c)) then
        deallocate(c)
    end if
    
    open(unit = iounit, file = trim(filename))
    read(iounit,*) s
    
    allocate(a(s,s))
    allocate(b(s))
    allocate(c(s))
    
    read(iounit,*) b
    read(iounit,*) c
    
    do i=1,s
        read(iounit,*) a(i,:)
    end do
    
    close(iounit)

end subroutine

subroutine readinitstate(filename,mi,xi,vi,n)
    
    character(len=*)                                            , intent(in)   :: filename
    real(kind=real_kind)    , allocatable   , dimension(:)      , intent(out)  :: mi        ! Mass of bodies
    real(kind=real_kind)    , allocatable   , dimension(:,:)    , intent(out)  :: xi,vi     ! Position and velocity of bodies
    integer                                                     , intent(out)  :: n         ! Number of bodies
    
    integer , parameter                 :: iounit = 2           ! Number required by Frotran for Input/Output

    if (allocated(mi)) then
        deallocate(mi)
    end if
    if (allocated(xi)) then
        deallocate(xi)
    end if
    if (allocated(vi)) then
        deallocate(vi)
    end if
    
    open(unit = iounit, file = trim(filename))
    read(iounit,*) n
    
    allocate(mi(n))
    allocate(xi(nd,n))
    allocate(vi(nd,n))
    
    read(iounit,*) mi
    
    do i=1,nd
        read(iounit,*) xi(i,:)
    end do
    do i=1,nd
        read(iounit,*) vi(i,:)
    end do
    
    close(iounit)

end subroutine

subroutine writeinitstate(iounit,t,mi,xi,vi,nrj,postoid,nb)

    integer                                                     , intent(in)    :: iounit   ! Unit of I/O flux
    real (kind=real_kind)                                       , intent(in)    :: t        ! Current time
    real (kind=real_kind)   , allocatable   , dimension(:)      , intent(in)    :: mi       ! Mass of bodies
    real (kind=real_kind)   , allocatable   , dimension(:,:)    , intent(in)    :: xi,vi    ! Position and velocity of bodies
    real (kind=real_kind)                                       , intent(in)    :: nrj      ! Energy of the system
    integer                 , allocatable   , dimension(:)      , intent(in)    :: postoid  ! ID of bodies
    integer                                                     , intent(in)    :: nb       ! Number of bodies
    
    character (len=4)                                                           :: varnum
    integer                                                                     :: i,j

    write(iounit,'(A,E18.12)',advance='no') "{'t':",t
    write(iounit,'(A)',advance='no') ",'x':{"
    
    do i=1,nb-1
        write(varnum,'(I4.4)') postoid(i)
        write(iounit,'(A,A,A)',advance='no') "'",varnum,"':["
        do j=1,nd-1
            write(iounit,'(E18.12,A)',advance='no')    xi(j,i),","
        end do
        write(iounit,'(E18.12,A)',advance='no')    xi(nd,i),"],"
    end do
    write(varnum,'(I4.4)') postoid(nb)
    write(iounit,'(A,A,A)',advance='no') "'",varnum,"':["
    do j=1,nd-1
        write(iounit,'(E18.12,A)',advance='no')    xi(j,nb),","
    end do
    write(iounit,'(E18.12,A)',advance='no')    xi(nd,nb),"]},"

    write(iounit,'(A)',advance='no') "'m':{"
    do i=1,nb-1
        write(varnum,'(I4.4)') postoid(i)
        write(iounit,'(A,A,A)',advance='no') "'",varnum,"':"
        write(iounit,'(E18.12,A)',advance='no')    mi(i),","
    end do
    write(varnum,'(I4.4)') postoid(nb)
    write(iounit,'(A,A,A)',advance='no') "'",varnum,"':"
    write(iounit,'(E18.12,A)',advance='no')    mi(nb),"}"

    write(iounit,'(A,E18.12)',advance='no') ",'H':",nrj

    write(iounit,'(A)')    "},"

end subroutine


subroutine writecurrentstate_nomasschange(iounit,t,xi,nrj,postoid,nb)

    integer                                                     , intent(in)    :: iounit   ! Unit of I/O flux
    real (kind=real_kind)                                       , intent(in)    :: t        ! Current time
    real (kind=real_kind)   , allocatable   , dimension(:,:)    , intent(in)    :: xi       ! Position of bodies
    integer                                                     , intent(in)    :: nb       ! Number of bodies
    integer                 , allocatable   , dimension(:)      , intent(in)    :: postoid  ! ID of bodies
    real (kind=real_kind)                                       , intent(in)    :: nrj      ! Energy of the system
    
    character (len=4)                                                           :: varnum
    integer                                                                     :: i,j


    write(iounit,'(A,E18.12)',advance='no') "{'t':",t
    write(iounit,'(A)',advance='no') ",'x':{"
    
    do i=1,nb-1
        write(varnum,'(I4.4)') postoid(i)
        write(iounit,'(A,A,A)',advance='no') "'",varnum,"':["
        do j=1,nd-1
            write(iounit,'(E18.12,A)',advance='no')    xi(j,i),","
        end do
        write(iounit,'(E18.12,A)',advance='no')    xi(nd,i),"],"
    end do
    write(varnum,'(I4.4)') postoid(nb)
    write(iounit,'(A,A,A)',advance='no') "'",varnum,"':["
    do j=1,nd-1
        write(iounit,'(E18.12,A)',advance='no')    xi(j,nb),","
    end do
    write(iounit,'(E18.12,A)',advance='no')    xi(nd,nb),"]}"

    write(iounit,'(A,E18.12)',advance='no') ",'H':",nrj
    
    write(iounit,'(A)')    "},"

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

subroutine compute_energy(mi,xi,vi,nb,res)

    real(kind=real_kind)    , dimension(:)      , intent(in)    :: mi       ! Mass of bodies
    real(kind=real_kind)    , dimension(:,:)    , intent(in)    :: xi,vi    ! Position and velocity of bodies
    integer                                     , intent(in)    :: nb       ! Number of bodies
    real(kind=real_kind)                        , intent(out)   :: res      ! Total energy of the system
    
    integer                                                     :: i,k,l
    real(kind=real_kind)                                        :: temp     ! temporary variable
    real(kind=real_kind)                                        :: kin,pot     ! Different types of energy
    real(kind=real_kind)    , dimension(nd)                     :: dx       ! Distance between two bodies
    
    kin = 0
    
    do k=1,nb
        temp = vi(1,k)*vi(1,k)
        do i=2,nd
            temp = temp + vi(i,k)*vi(i,k)    
        end do
        kin = kin + mi(k)*temp
    end do
    
    kin = kin/2
    
    pot = 0
    
    do k=1,nb
        do l=k+1,nb
            dx = xi(:,k) - xi(:,l)
            temp = dx(1)*dx(1)
            do i=2,nd
                temp = temp + dx(i)*dx(i)
            end do
            pot = pot + mi(k)*mi(l)*potential(temp)
        end do
    end do
    
    pot = Guniv*pot
    
    res = kin + pot
    
end subroutine

include 'forcemodel.f90'



