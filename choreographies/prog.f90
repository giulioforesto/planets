! Sets the number of threads to be created by OpenMP

!$ call omp_set_num_threads(numthreads)

! Calls random seed initialization

call init_random_seed()


! Reads initial Fourrier coefficients
if (restartfromlast) then
    call readfouriercoeffs(nc,mc,nb,maxnb,nf,maxnf,abf,fourrierexportcoefffilename)
else
    call readfouriercoeffs(nc,mc,nb,maxnb,nf,maxnf,abf,fourrierimportcoefffilename)
end if
! If data was not available, we start from a random initial state

! Reads integration method from file

!~ call readgaussmeth(xi,wi,si,gaussmethfilename)


si = 3*maxnf
allocate(wi(si))
allocate(xi(si))

do i=1,si
    xi(i) = ((i-1)*2.0_16 - 1.0_16)/(si)
    wi(i) = 2.0_16 / (si)
end do








if (.not. (allocated(abf))) then
    
    allocate(   abf(nd,2,nc,0:maxnf)  )
    
    abf = 0
    
    do i=1,nd
        do j=1,2
            do k=1,nc
                do l=1,min(nf(k),maxnfinit)
                    
                    call random_number(nran)
!~                     abf(i,j,k,l) = nran * (1.0_8/(l+1))
!~                     abf(i,j,k,l) = 2*nran-1
!~                     abf(i,j,k,l) = (2*nran-1)* (1.0_8/(l+1))
!~                     abf(i,j,k,l) = (2*nran-1)* ((1.0_8*(l+1))**(-1.5))
                    abf(i,j,k,l) = (2*nran-1)* ((1.0_8*(l+1))**(-1))/3
                    
                end do
            end do
        end do
    end do

end if

allocate(sincostable(2,si,nc,maxnb,0:maxnf))
call evaltrig(xi,si,nc,nb,nf,maxnf,sincostable)

allocate(gradact(nd,2,nc,0:maxnf))
allocate(abfs(nd,2,nc,0:maxnf))

call evalaction(nd,si,wi,nc,nb,maxnb,mc,nf,maxnf,sincostable,abf,act)

call evalgradaction(nd,si,wi,nc,nb,maxnb,mc,nf,maxnf,sincostable,abf,gradact)



allocate(gradactdf(nd,2,nc,0:maxnf))
call evalgradactiondifffin(nd,si,wi,nc,nb,maxnb,mc,nf,maxnf,sincostable,abf,gradactdf,1d-7)


gradactdf = gradactdf - gradact
call evalnormgradaction(gradactdf,nc,nf,maxnf,ninf,n1,n2)

print*,ninf,n1,n2

pause



do k=1,maxnf
    gradact(:,:,:,k) = gradact(:,:,:,k) /((k)**2)
end do


call evalnormgradaction(gradact,nc,nf,maxnf,ninf,n1,n2)


iopt = 0
distini = distiniini
do while ((iopt < nminopt).or.((iopt < nmaxopt).and.(ninf > ninfmax).and.(n1 > n1max).and.(n2 > n2max)))
    
    print*,iopt
    print*,'act = ',act
    print*,ninf,n1,n2
    print*,ninfmax,n1max,n2max
    
    iopt = iopt+1
    
    distg = 0
    distm = distini
    distd = (1+gold)*distini

    abfs = abf  - distd*gradact
    call evalaction(nd,si,wi,nc,nb,maxnb,mc,nf,maxnf,sincostable,abfs,actd)
    
    if (actd < act) then

        abf = abf  - distd*gradact
        act = actd    
        distm = distd
        nlin = 1
    else
    
        
        
        actg = act
        abfs = abf  - distm*gradact
        call evalaction(nd,si,wi,nc,nb,maxnb,mc,nf,maxnf,sincostable,abfs,actm)




        computedg = .true.
        ! Golden search between  actg and actd
        
        
        nlin = 2
        
    !~     do while ((distd-distg) > distmin)
        do while ((distd-distg) > (distini/convratio))
            nlin = nlin +1
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
    end if

    call evalgradaction(nd,si,wi,nc,nb,maxnb,mc,nf,maxnf,sincostable,abf,gradact)
    call evalnormgradaction(gradact,nc,nf,maxnf,ninf,n1,n2)
    gradact = gradact    
    
    do k=1,maxnf
!~     
!~         if (iopt < 100) then
!~             gradact(:,:,:,k) = gradact(:,:,:,k) /((k)**1.5)
!~         else
!~             gradact(:,:,:,k) = gradact(:,:,:,k) /((k)**1.5)
!~         end if
!~         call random_number(nran)
        gradact(:,:,:,k) = gradact(:,:,:,k) /(k**(2))
    end do
    
    
    print*,'dist = ',distm, distini
    print*,nlin
    distini = min(max(distm/2 , distmin),distmax)
    
    
end do

print*,iopt
print*,'act = ',act
print*,ninf,n1,n2
print*,ninfmax,n1max,n2max



call print_init_state(nc,nb,mc,nf,abf,exportinitstatefilename)
call print_cheat_traj(nc,nb,mc,nf,abf,3,3000,exportcheattrajfilename)
call writefouriercoeffs(nc,mc,nb,nf,maxnf,abf,fourrierexportcoefffilename)

