! Functions concerning compensated polynomial evaluation.
! Maximum optimisation level : -O3
! DO NOT compile with -ffast-math or -Ofast

subroutine polyeval_horner(P,n,a,res)  ! Evaluates polynom P of degree n at a and stores result in res

    real (kind = real_kind_eft) , dimension(0:n), intent(in)    :: P
    integer                                     , intent(in)    :: n
    real (kind = real_kind_eft)                 , intent(in)    :: a
    real (kind = real_kind_eft)                 , intent(out)   :: res
    
    integer                                                     :: i
    
    res = P(n)
    
    do i=n-1,0,-1
        res = a*res + P(i)
    end do
    
end subroutine


subroutine efttwosum(a,b,x,y)

    real (kind = real_kind_eft) , intent(in)    :: a,b
    real (kind = real_kind_eft) , intent(out)   :: x,y
    
    real (kind = real_kind_eft)                 :: z
    
    x = a+b
    z = x-a
    y = (a-(x-z))+(b-z)

end subroutine

subroutine eftsplit(a,x,y)
    
    real (kind = real_kind_eft) , intent(in)    :: a
    real (kind = real_kind_eft) , intent(out)   :: x,y
    
    real (kind = real_kind_eft)                 :: z
    integer (kind = 8)          , parameter     :: r = digits(one)/2 + 1
    
    z = a*(2**r + 1)
    x = z - (z-a) 
    y = a - x
    
end subroutine

subroutine efttwoprod(a,b,x,y)
    
    real (kind = real_kind_eft) , intent(in)    :: a,b
    real (kind = real_kind_eft) , intent(out)   :: x,y
    
    real (kind = real_kind_eft)                 :: ah,al,bh,bl
    
    x = a*b
    
    call eftsplit(a,ah,al)
    call eftsplit(b,bh,bl)
    
    y = al*bl - (((x - ah*bh) - al*bh) - ah*bl)
    
end subroutine

subroutine efthorner(P,n,a,res,ppi,psi)

    real (kind = real_kind_eft) , dimension(0:n)    , intent(in)    :: P
    integer                                         , intent(in)    :: n
    real (kind = real_kind_eft)                     , intent(in)    :: a
    real (kind = real_kind_eft)                     , intent(out)   :: res
    real (kind = real_kind_eft) , dimension(0:n-1)  , intent(out)   :: ppi
    real (kind = real_kind_eft) , dimension(0:n-1)  , intent(out)   :: psi
    
    integer                                                     :: i
    real (kind = real_kind_eft)                                     :: x

    res = P(n)
    
    do i=(n-1),0,-1
        call efttwoprod(res,a,x,ppi(i))
        call efttwosum(x,P(i),res,psi(i))
    end do

end subroutine

subroutine eftvecsum(p,n,q)

    real (kind = real_kind_eft) , dimension(n)  , intent(in)    :: p
    integer                                     , intent(in)    :: n
    real (kind = real_kind_eft) , dimension(n)  , intent(out)   :: q
    
    
    real (kind = real_kind_eft)                                 :: a
    integer                                                     :: i
    
    q(1) = p(1)
    do i=2,n
        call efttwosum(p(i),q(i-1),q(i),a)
        q(i-1) = a
    end do

end subroutine

subroutine sumk(p,n,k,res)

    real (kind = real_kind_eft) , dimension(n)  , intent(inout) :: p
    integer                                     , intent(in)    :: n
    integer                                     , intent(in)    :: k
    real (kind = real_kind_eft)                 , intent(out)   :: res

    real (kind = real_kind_eft) , dimension(n)                  :: q
    integer                                                     :: i
    
    do i=1,(k-1)
        call eftvecsum(p,n,q)
        p=q
    end do
    res = p(1)
    do i=2,n
        res = res + p(i)
    end do

end subroutine

subroutine efthornerk(P,n,a,k,hi,pi)

    real (kind = real_kind_eft) , dimension(0:n)                , intent(in)    :: P
    integer                                                     , intent(in)    :: n
    real (kind = real_kind_eft)                                 , intent(in)    :: a
    integer                                                     , intent(in)    :: k
    real (kind = real_kind_eft) , dimension(1:(2**(k-1) - 1))   , intent(out)   :: hi
    real (kind = real_kind_eft) , dimension(0:n,1:2**k-1)       , intent(out)   :: pi

    integer                                                                     :: i,j,l
    
    hi = 0
    pi = 0
    
    i=1
    pi(:,1) = P
    
    
    do j=1,k-1
        do l=i,(2*i-1)
            call efthorner(pi(0:n+1-j,l),n+1-j,a,hi(l),pi(0:n-j,2*l),pi(0:n-j,2*l+1))
        end do
        i = 2*i
    end do
    
end subroutine

subroutine comphornerk(P,n,a,k,res)

    real (kind = real_kind_eft) , dimension(0:n)    , intent(in)    :: P
    integer                                         , intent(in)    :: n
    real (kind = real_kind_eft)                     , intent(in)    :: a
    integer                                         , intent(in)    :: k
    real (kind = real_kind_eft)                     , intent(out)   :: res
        
    real (kind = real_kind_eft) , dimension(1:2**k-1)               :: hi
    real (kind = real_kind_eft) , dimension(0:n,1:2**k-1)           :: pi
    integer                                                         :: i
    
    call efthornerk(P,n,a,k,hi(1:(2**(k-1) - 1)),pi)
    
    do i=2**(k-1),2**k - 1
        call polyeval_horner(pi(0:n+1-k,i),n+1-k,a,hi(i))
    end do

    call sumk(hi,2**k - 1,k,res)
    
end subroutine

subroutine eft_incrsum(y,d,e)       ! cf Geometric numerical integration - 2005 - Hairer, Lubich, Wanner pp 323

        real (kind = real_kind_eft) , intent(inout)     :: y
        real (kind = real_kind_eft) , intent(in)        :: d
        real (kind = real_kind_eft) , intent(inout)     :: e
        
        real (kind = real_kind_eft)                     :: a
        
!~         print*,'1'
!~         print*,'y',y
!~         print*,'d',d
!~         print*,'e',e
        
        a = y
        e = e + d
        y = a + e
        e = e + (a - y)
        
!~         print*,'2'
!~         print*,'y',y
!~         print*,'d',d
!~         print*,'e',e
        
end subroutine
