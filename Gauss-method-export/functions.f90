subroutine polyeval_horner(P,n,a,res)  ! Evaluates polynom P of degree n at a and stores result in res

    real (kind = real_kind) , dimension(0:n), intent(in)    :: P
    integer                                 , intent(in)    :: n
    real (kind = real_kind)                 , intent(in)    :: a
    real (kind = real_kind)                 , intent(out)   :: res
    
    integer                                                 :: i
    
    res = P(n)
    
    do i=n-1,0,-1
        res = a*res + P(i)
    end do
    
end subroutine

subroutine findpolyroot_dichot(P,n,a,b,res)    ! Finds root of polynomial P of degree n between a and b assuming there is one using dichotomy

    real (kind = real_kind) , dimension(0:n)    , intent(in)    :: P
    integer                                     , intent(in)    :: n
    real (kind = real_kind)                     , intent(inout) :: a,b
    real (kind = real_kind)                     , intent(out)   :: res
    
    real (kind = real_kind)                                     :: pa,pb,pi
    real (kind = real_kind)                                     :: eps
    logical                                                     :: papos,pbpos
    
    
    call polyeval_horner(P,n,a,pa)
    call polyeval_horner(P,n,b,pb)
    
    papos = (pa > 0)
    pbpos = (pb > 0)
    
    if (papos .eqv. pbpos) then
        print*, 'Error : Cannot find solution'
        print*, 'a =',a
        print*, 'pa =',pa
        print*, 'b =',b
        print*, 'pb =',pb
        call exit(0)
    else
        
        eps = 4*epsilon(a)
        
        do while ((b-a) > eps)
            res = (a + b)/2
            call polyeval_horner(P,n,res,pi)
            if (pi == 0) then
                return 
            else if (papos .eqv. (pi > 0)) then
                a = res
                pa = pi
            else
                b = res
                pb = pi
            end if
        end do
    end if
    
end subroutine

subroutine findpolyroot_sec(P,n,a,b,res)    ! Finds root of polynomial P of degree n between a and b assuming there is one using the secant method

    real (kind = real_kind) , dimension(0:n)    , intent(in)    :: P
    integer                                     , intent(in)    :: n
    real (kind = real_kind)                     , intent(inout) :: a,b
    real (kind = real_kind)                     , intent(out)   :: res
    
    real (kind = real_kind)                                     :: pa,pb,pi
    real (kind = real_kind)                                     :: eps
    logical                                                     :: papos,pbpos
    
    
    call polyeval_horner(P,n,a,pa)
    call polyeval_horner(P,n,b,pb)
    
    papos = (pa > 0)
    pbpos = (pb > 0)
    
    if (papos .eqv. pbpos) then
        print*, 'Error : Cannot find solution'
        print*, 'pa =',pa
        print*, 'pb =',pb
        call exit(0)
    else
        
        eps = epsilon(a)
        
        do while ((b-a) > eps)
            res = (b*pa - a*pb)/(pa-pb)
            call polyeval_horner(P,n,res,pi)
            if (pi == 0) then
                return 
            else if (papos .eqv. (pi > 0)) then
                a = res
                pa = pi
            else
                b = res
                pb = pi
            end if
        end do
    end if
    
end subroutine

subroutine writebutchertable(a,b,c,s,prec)
    
    real (kind = real_kind) , dimension(s,s)    , intent(in)    :: a
    real (kind = real_kind) , dimension(s)      , intent(in)    :: b,c
    integer                                     , intent(in)    :: s,prec
    
    character(len=50)                                           :: filename
    
    integer , parameter                 :: iounit = 2       ! Number required by Fortran for Input/Output
    integer                             :: i
    
    
    write(filename, '(A25,I3,A4,I2,A4)') "./output/gauss_butch_table", s,"prec",prec,".txt"
    
    open(unit = iounit, file = trim(filename))
    
    write(iounit,*) b
    write(iounit,*) c
    
    do i=1,s
        write(iounit,*) a(i,:)
    end do
    
    close(iounit)
    
end subroutine

subroutine writegaussmeth(x,w,s,prec)
    
    real (kind = real_kind) , dimension(s)      , intent(in)    :: x,w
    integer                                     , intent(in)    :: s,prec
    
    character(len=50)                                           :: filename
    
    integer , parameter                 :: iounit = 2       ! Number required by Fortran for Input/Output
    integer                             :: i
    
    
    write(filename, '(A22,I3,A4,I2,A4)') "./output/gauss_int_meth", s,"prec",prec,".txt"
    
    open(unit = iounit, file = trim(filename))
    
    write(iounit,*) w
    write(iounit,*) x
    
    close(iounit)
    
end subroutine

subroutine pivot_gauss(A,b,n)   ! Résoud sur place le systeme Ax=b avec la méthode du pivot de Gauss "naïve".
    
    real (kind = real_kind) , dimension(n,n)    , intent(inout) :: A
    real (kind = real_kind) , dimension(n)      , intent(inout) :: b
    integer                                     , intent(in)    :: n

    integer                                                     :: i,j,k
    integer                 , dimension(n)                      :: swap
    real (kind = real_kind)                                     :: acc
    
    acc = 10*epsilon(b)
    
    do i=1,n
        swap(i)=i
    end do

    do i=1,n-1
        
        j=i
        do while (abs(A(swap(j),i)) < acc)
            j=j+1
        end do
        
        if (j .ne. i) then
            k = swap(j)
            swap(j) = swap(i)
            swap(i) = k
        end if
        
        b(swap(i)) = b(swap(i))/A(swap(i),i)
        A(swap(i),i+1:n) = A(swap(i),i+1:n)/A(swap(i),i)
        
        do j=i+1,n
            b(swap(j)) = b(swap(j)) - b(swap(i)) * A(swap(j),i)
            A(swap(j),i+1:n) = A(swap(j),i+1:n) - A(swap(i),i+1:n)*A(swap(j),i)
        end do
        
    end do
    
    b(swap(n)) = b(swap(n)) / A(swap(n),n)
    
    do i=n-1,1,-1
        acc = real(0,real_kind)
        do j=i+1,n
            acc = acc + A(swap(i),j)*b(swap(j))
        end do
        b(swap(i)) = b(swap(i)) - acc
    end do

end subroutine
