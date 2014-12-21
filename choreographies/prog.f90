! Sets the number of threads to be created by OpenMP

!$ call omp_set_num_threads(numthreads)

! Calls random seed initialization

call init_random_seed()

! Reads integration method from file

call readgaussmeth(xi,wi,si,gaussmethfilename)

! Reads initial Fourrier coefficients
if (restartfromlast) then
    call readfouriercoeffs(nc,mc,nb,maxnb,nf,maxnf,abf,fourrierexportcoefffilename)
else
    call readfouriercoeffs(nc,mc,nb,maxnb,nf,maxnf,abf,fourrierimportcoefffilename)
end if
! If data was not available, we start from a random initial state

if (.not. (allocated(abf))) then
    
    allocate(   abf(nd,2,nc,0:maxnf)  )
    
    do i=1,nd
        do j=1,2
            do k=1,nc
                do l=0,min(nf(k),maxnfinit)
                    
                    call random_number(nran)
                    abf(i,j,k,l) = nran
                    
                end do
            end do
        end do
    end do

end if

allocate(sincostable(2,si,nc,maxnb,0:maxnf))
call evaltrig(xi,si,nc,nb,nf,maxnf,sincostable)

allocate(gradact(nd,2,nc,0:maxnf))
allocate(abfs(nd,2,nc,0:maxnf))


!~ print*,si
!~ print*,nc
!~ print*,nb
!~ print*,mc

act = 0

!~ abf = 0
!~ abf(1,1,1,1) = 1
!~ abf(2,2,1,1) = 1

call evalaction(nd,si,wi,nc,nb,maxnb,mc,nf,maxnf,sincostable,abf,act)
call evalgradaction(nd,si,wi,nc,nb,maxnb,mc,nf,maxnf,sincostable,abf,gradact)
!~ print*, abf
!~ 
!~ print*, '---'
!~ print*,act
!~ print*, '---'
!~ print*,gradact

call evalnormgradaction(gradact,nc,nf,maxnf,ninf,n1,n2)

iopt = 0

do while ((iopt < nminopt).or.((iopt < nmaxopt).and.(ninf > ninfmax).and.(n1 > n1max).and.(n2 > n2max)))
    
    print*,iopt
    print*,'act = ',act
    print*,ninf,n1,n2
    print*,ninfmax,n1max,n2max
    
    iopt = iopt+1
    
    distg = 0
    distm = distini
    distd = (1+gold)*distini
    
    actg = act
    abfs = abf  - distm*gradact
    call evalaction(nd,si,wi,nc,nb,maxnb,mc,nf,maxnf,sincostable,abfs,actm)
    abfs = abf  - distd*gradact
    call evalaction(nd,si,wi,nc,nb,maxnb,mc,nf,maxnf,sincostable,abfs,actd)
    
    
    do while (actd < actm)
!~         print*, iopt
        distg = distm
        distm = distd
        distd = gold*distd
    
        abfs = abf  - distd*gradact
        
        actg = actm
        actm = actd
        call evalaction(nd,si,wi,nc,nb,maxnb,mc,nf,maxnf,sincostable,abfs,actd)
        
    end do

    computedg = .true.
    ! Golden search between  actg and actd
    
    do while ((distd-distg) < distmin)
        if (computedg) then
            distm2 = distd -invgold*(distd - distg)
            abfs = abf  - distm2*gradact
            call evalaction(nd,si,wi,nc,nb,maxnb,mc,nf,maxnf,sincostable,abfs,actm2)
            if (actm < actm2) then
                actd = actm2
                distd = distm2
                computedg = .false.
            else
                actg = actm
                distg = distm
                actm = actm2
                distm = distm2
            end if
        else
            distm2 = distg +invgold*(distd - distg)
            abfs = abf  - distm2*gradact
            call evalaction(nd,si,wi,nc,nb,maxnb,mc,nf,maxnf,sincostable,abfs,actm2)
            if (actm < actm2) then
                actg = actm2
                distg = distm2
                computedg = .true.
            else
                distd = distm
                actd = actm
                distm = distm2
                actm = actm2
            end if
        end if
    end do
    
    abf = abf  - distm*gradact
    act = actm
    call evalgradaction(nd,si,wi,nc,nb,maxnb,mc,nf,maxnf,sincostable,abf,gradact)
    call evalnormgradaction(gradact,nc,nf,maxnf,ninf,n1,n2)    
end do



call print_init_state(nc,nb,mc,nf,abf,exportinitstatefilename)
call print_cheat_traj(nc,nb,mc,nf,abf,3,3000,exportcheattrajfilename)
call writefouriercoeffs(nc,mc,nb,nf,maxnf,abf,fourrierexportcoefffilename)

