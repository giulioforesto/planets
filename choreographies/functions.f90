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
                do k=1,nf(i)
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
            do j=1,nb(i)-1
                do p=i,nc
                    do q=j+1,nb(p)
                        xijpq = x(:,i,j) - x(:,p,q)
                        xijpq2 = xijpq(1)*xijpq(1)
                        do d=2,nd
                            xijpq2 = xijpq2 + xijpq(d)*xijpq(d)
                        end do
                        
                        pot = pot + mc(i)*mc(p)*potential(xijpq2)
                    end do
                end do
            end do
        end do
        
        pot = Guniv*pot
        
        lag = kin - pot
        res = res + wi(l)*lag
    end do
    !$omp end do
    !$omp end parallel

end subroutine
