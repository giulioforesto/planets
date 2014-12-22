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


! Evaluates the trigonometric monomials and stores results
subroutine evaltrig(xi,si,nc,nb,nf,maxnf,sincostable)

    integer                                                     , intent(in)    :: nc,si
    integer                 , dimension(nc)                     , intent(in)    :: nb,nf
    real(kind=real_kind)    , dimension(si)                     , intent(in)    :: xi
    integer                                                     , intent(in)    :: maxnf
    real(kind=real_kind)    , dimension(2,si,nc,maxnb,0:maxnf)  , intent(out)   :: sincostable

    integer                 :: i,j,k,l,m,n
    real(kind=real_kind)    :: t

    sincostable = 0
    sincostable(1,:,:,:,0) = 1
    !~ sincostable(2,:,:,:,0) = 0

    !$omp parallel default(private) shared(sincostable,si,nc,nb,nf)	
    !$omp do    
    do l=1,si
        do i=1,nc
            do j=1,nb(i)
                t = pi*(xi(l)+1 - ((j-1)*2.0_real_kind )/nb(i))
                do k=1,nf(i)
                    sincostable(1,l,i,j,k) = cos(k*t)
                    sincostable(2,l,i,j,k) = sin(k*t)
                end do
            end do
        end do
    end do
    !$omp end do
    !$omp end parallel
 end subroutine
 
 subroutine evalaction(nd,si,wi,nc,nb,maxnb,mc,nf,maxnf,sincostable,abf,res)
    integer                                                     , intent(in)    :: nc,si,nd
    integer                 , dimension(nc)                     , intent(in)    :: nb,nf
    integer                                                     , intent(in)    :: maxnf,maxnb
    real(kind=real_kind)    , dimension(nc)                     , intent(in)    :: mc
    real(kind=real_kind)    , dimension(si)                     , intent(in)    :: wi
    real(kind=real_kind)    , dimension(2,si,nc,maxnb,0:maxnf)  , intent(in)    :: sincostable
    real(kind=real_kind)    , dimension(nd,2,nc,0:maxnf)        , intent(in)    :: abf
    real(kind=real_kind)                                        , intent(out)   :: res

    real(kind=real_kind)        :: lag, kin, pot
    real(kind=real_kind)        :: v(nd), v2, x(nd,nc,maxnb), xijpq(nd), xijpq2
    integer                     :: l,i,j,k,p,q,d
    res = 0

    !$omp parallel default(private) shared(sincostable,si,nc,nb,nf,abf,mc)	reduction( + : res )
    !$omp do 
    do l=1,si
        kin = 0
        pot = 0
        x = 0
        do i=1,nc
            do j=1,nb(i)
                v = 0
                do k=0,nf(i)
                    v = v + k*(abf(:,2,i,k)*sincostable(1,l,i,j,k) - abf(:,1,i,k)*sincostable(2,l,i,j,k) )
                    x(:,i,j) = x(:,i,j) + (abf(:,2,i,k)*sincostable(2,l,i,j,k) + abf(:,1,i,k)*sincostable(1,l,i,j,k) )
                end do
                v2 = v(1)*v(1)
                do d=2,nd
                    v2 = v2 + v(d)*v(d)
                end do
                kin = kin + mc(i) * v2
            end do
        end do

        kin = kin / 2

        do i=1,nc
            do j=1,nb(i)
                do p=i,nc
                    if (p .eq. i) then
                        do q=j+1,nb(p)
                            xijpq = x(:,i,j) - x(:,p,q)
                            xijpq2 = xijpq(1)*xijpq(1)
                            do d=2,nd
                                xijpq2 = xijpq2 + xijpq(d)*xijpq(d)
                            end do
                            
                            pot = pot + mc(i)*mc(p)*potential(xijpq2)
                        end do
                    else
                        do q=1,nb(p)
                            xijpq = x(:,i,j) - x(:,p,q)
                            xijpq2 = xijpq(1)*xijpq(1)
                            do d=2,nd
                                xijpq2 = xijpq2 + xijpq(d)*xijpq(d)
                            end do
                            
                            pot = pot + mc(i)*mc(p)*potential(xijpq2)
                        end do
                    end if
                end do
            end do
        end do
        
        lag = kin - Guniv*pot
        res = res + wi(l)*lag
    end do
    !$omp end do
    !$omp end parallel

end subroutine


subroutine evalgradaction(nd,si,wi,nc,nb,maxnb,mc,nf,maxnf,sincostable,abf,res)
    integer                                                     , intent(in)    :: nc,si,nd
    integer                 , dimension(nc)                     , intent(in)    :: nb,nf
    integer                                                     , intent(in)    :: maxnf,maxnb
    real(kind=real_kind)    , dimension(nc)                     , intent(in)    :: mc
    real(kind=real_kind)    , dimension(si)                     , intent(in)    :: wi
    real(kind=real_kind)    , dimension(2,si,nc,maxnb,0:maxnf)  , intent(in)    :: sincostable
    real(kind=real_kind)    , dimension(nd,2,nc,0:maxnf)        , intent(in)    :: abf
    real(kind=real_kind)    , dimension(nd,2,nc,0:maxnf)        , intent(out)   :: res

    real(kind=real_kind)        :: gradlag(nd,2,nc,0:maxnf) 
    real(kind=real_kind)        :: v(nd), v2, x(nd,nc,maxnb), xijpq(nd), xijpq2 ,fijpq(nd)
    integer                     :: l,i,j,k,p,q,d
    res = 0

    !$omp parallel default(private) shared(sincostable,si,nc,nb,nf,abf,mc)	reduction( + : res )
    !$omp do 
    do l=1,si
        gradlag = 0
        x = 0
        do i=1,nc
            do j=1,nb(i)
                v = 0
                do k=0,nf(i)
                    v = v + k*(abf(:,2,i,k)*sincostable(1,l,i,j,k) - abf(:,1,i,k)*sincostable(2,l,i,j,k) )
                    x(:,i,j) = x(:,i,j) + (abf(:,2,i,k)*sincostable(2,l,i,j,k) + abf(:,1,i,k)*sincostable(1,l,i,j,k) )
                end do
                v = mc(i)*v
                do k=1,nf(i)
                    gradlag(:,1,i,k) = gradlag(:,1,i,k) -k*sincostable(2,l,i,j,k)*v
                    gradlag(:,2,i,k) = gradlag(:,2,i,k) +k*sincostable(1,l,i,j,k)*v
                end do
            end do
        end do

        do i=1,nc
            do j=1,nb(i)
                do p=i,nc
                    if (p .eq. i) then
                        do q=j+1,nb(p)
                            xijpq = x(:,i,j) - x(:,p,q)
                            xijpq2 = xijpq(1)*xijpq(1)
                            do d=2,nd
                                xijpq2 = xijpq2 + xijpq(d)*xijpq(d)
                            end do
                            fijpq =  Guniv*xijpq * forceoverdist(xijpq2)
                            do k=0,nf(i)
                                gradlag(:,1,i,k) = gradlag(:,1,i,k) &
                                + (sincostable(1,l,i,q,k) - sincostable(1,l,i,j,k)) * fijpq
                                gradlag(:,2,i,k) = gradlag(:,2,i,k) &
                                + (sincostable(2,l,i,q,k) - sincostable(2,l,i,j,k)) * fijpq                            
                            end do
                        end do
                    else
                        do q=1,nb(p)
                            xijpq = x(:,i,j) - x(:,p,q)
                            xijpq2 = xijpq(1)*xijpq(1)
                            do d=2,nd
                                xijpq2 = xijpq2 + xijpq(d)*xijpq(d)
                            end do
                            fijpq =  Guniv*xijpq * forceoverdist(xijpq2)
                            do k=0,nf(i)
                                gradlag(:,1,i,k) = gradlag(:,1,i,k) &
                                - sincostable(1,l,i,j,k) * fijpq
                                gradlag(:,2,i,k) = gradlag(:,2,i,k) &
                                - sincostable(2,l,i,j,k) * fijpq                                 
                                gradlag(:,1,p,k) = gradlag(:,1,p,k) &
                                + sincostable(1,l,p,q,k) * fijpq
                                gradlag(:,2,p,k) = gradlag(:,2,p,k) &
                                + sincostable(2,l,p,q,k) * fijpq                                 
                            end do
                        end do
                    end if
                end do
            end do
        end do
        
        res = res + wi(l)*gradlag
    end do
    !$omp end do
    !$omp end parallel

end subroutine

subroutine evalnormgradaction(gradact,nc,nf,maxnf,ninf,n1,n2)

    real(kind=real_kind)    , dimension(nd,2,nc,0:maxnf), intent(in)    :: gradact
    integer                                             , intent(in)    :: nc,maxnf
    integer                 , dimension(nc)             , intent(in)    :: nf
    real(kind=real_kind)                                , intent(out)   :: ninf,n1,n2
    
    integer                 :: i,j,k,d
    real(kind=real_kind)    :: curabs
    
    ninf = 0
    n1 = 0
    n2 = 0
    
    do i=1,nc
        do k=1,nf(i)
            do d=1,nd
                do j=1,2
                    curabs = abs(gradact(d,j,i,k))
                    if (ninf < curabs) then
                        ninf = curabs
                    end if
                    n1 = n1 + curabs
                    n2 = n2 + curabs*curabs
                end do
            end do
        end do
    end do
    n2 = sqrt(n2)
    
end subroutine
