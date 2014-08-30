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

subroutine writeinitstate(iounit,t,mi,xi,nb,nd)

    integer                                                     , intent(in)    :: iounit   ! Unit of I/O flux
    real (kind=real_kind)                                       , intent(in)    :: t        ! Current time
    real (kind=real_kind)   , allocatable   , dimension(:)      , intent(in)    :: mi       ! Mass of bodies
    real (kind=real_kind)   , allocatable   , dimension(:,:)    , intent(in)    :: xi       ! Position and velocity of bodies
    integer                                                     , intent(in)    :: nb       ! Number of bodies
    integer                                                     , intent(in)    :: nd       ! Number of space dimensions
    
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

    write(iounit,'(A)')    "}"

end subroutine


subroutine writetoend_currentstate_nomasschange(iounit,t,xi,nb,nd)

    integer                                                     , intent(in)    :: iounit   ! Unit of I/O flux
    real (kind=real_kind)                                       , intent(in)    :: t        ! Current time
    real (kind=real_kind)   , allocatable   , dimension(:,:)    , intent(in)    :: xi       ! Position and velocity of bodies
    integer                                                     , intent(in)    :: nb       ! Number of bodies
    integer                                                     , intent(in)    :: nd       ! Number of space dimensions
    
    
    character (len=4)                                                           :: varnum
    integer                                                                     :: i,j

!~     rewind(iounit)

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
    
    write(iounit,'(A)')    "}"

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
