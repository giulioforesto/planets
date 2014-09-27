subroutine readgaussmeth(x,w,s,filename)
    
    real (kind = real_kind) , dimension(:)  , allocatable   , intent(out)   :: x,w
    integer                                                 , intent(out)   :: s
    character(len=50)                                       , intent(in)    :: filename
    
    integer , parameter                 :: iounit = 2       ! Number required by Fortran for Input/Output
    
!~     write(filename, '(A23,I3,A4,I2,A4)') "./output/gauss_int_meth", s,"prec",prec,".txt"
    
    open(unit = iounit, file = trim(filename))

    read(iounit,*) s    
    
    if allocated(x) then
        deallocate(x)
    end if
    
    if allocated(w) then
        deallocate(w)
    end if
    
    
    allocate(x(s))
    allocate(w(s))
    
    
    read(iounit,*) w
    read(iounit,*) x
    
    close(iounit)
    
end subroutine
