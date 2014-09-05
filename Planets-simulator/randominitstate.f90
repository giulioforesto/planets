! Creates a random initial configuration

nb = nbinit

allocate(mi(nb))
allocate(xi(nd,nb))
allocate(vi(nd,nb))

call init_random_seed()

do i=1,nb

!~     ! Distributes masses logarithmically
!~     call random_number(nran)
!~     b = -log(nran)
!~     mi(i) =  b*mmaxinit
    mi(i) =  mmaxinit

    ! Distributes position uniformly
    do q=1,nd
        call random_number(nran)
        xi(q,i) =  nran*xmaxinit
    end do

    ! Distributes speed with Maxwell distribution
    do q=1,nd
        call random_number(nran)
        b = sqrt(-log(nran))
        call random_number(nran)
        a = 2.0*pi*nran
        vi(q,i) =  b*sin(a)*vmeaninit
    end do
end do
