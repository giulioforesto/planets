! Sets the number of threads to be created by OpenMP

!$ call omp_set_num_threads(numthreads)

! Read method coefficients
call readbutchertable(butchtablefilename,a_butch,b_butch,c_butch,ns)

if (loadinitstate) then
    ! Read initial state from file
    call readinitstate(initstatefilename,mi,xi,vi,nb)
else
    ! Creates initial state randomly
    include 'randominitstate.f90'
end if
! Change of frame where center of mass is ALWAYS at origin

if (centerinit) then
    xmoy = 0
    vmoy = 0
    mtot = 0
    do i=1,nb
        xmoy = xmoy + xi(:,i)
        vmoy = vmoy + mi(i)*vi(:,i)
        mtot = mtot + mi(i)
    end do
    
    xmoy = xmoy / nb
    vmoy = vmoy / mtot
    
    do i=1,nb
        xi(:,i) = xi(:,i) - xmoy
        vi(:,i) = vi(:,i) - vmoy
    end do
    
end if

! Set memory and variables up

t = 0
teft = 0
dt = dtinit
nrjoff = 0

allocate(postoid(nb))
allocate(fijnow(nd,nb,nb))
allocate(xinow(nd,nb))
allocate(kxi(nd,nb,ns))
allocate(kvi(nd,nb,ns))
allocate(vinow(nd,nb))


if (useeft) then
    allocate(xieft(nd,nb))
    allocate(vieft(nd,nb))
    xieft = 0
    vieft = 0
end if

do i=1,nb
    postoid(i) = i
end do
currentid = nb+1

if (.not. explicitRK) then
    
    dt2 = dt*dt
    
    allocate(a_butch2(ns,ns))
    a_butch2 = matmul(a_butch,a_butch)

    allocate(zxi0(nd,nb,ns))    
    allocate(zxi1(nd,nb,ns))
    allocate(zxi2(nd,nb,ns))    
    
end if

! Write initial state in output file

t_o = 0
open(unit = outiounit, file = trim(outputfilename), access='sequential', action='write',position='rewind')
write(outiounit,'(A)')    "["

call compute_energy(mi,xi,vi,nb,nrj)
call writeinitstate(outiounit,t,mi,xi,vi,nrj,postoid,nb)
nrjinit = nrj

! Main loop

do while (t < tf)
    
    if (explicitRK) then
        ! The method is treated explicitely
        
        include 'compute_explicit.f90'
                
    else
        ! The method is treated implicitely
        
        include 'solve_implicit.f90'
        
    end if
    
    ! Update current time
    
    if (useeft) then
        call eft_incrsum(t,dt,teft)
    else
        t = t + dt
    end if
    
    
    ! Write output
    
    if (t > t_o + dto) then
        call compute_energy(mi,xi,vi,nb,nrj)
        nrj = nrj + nrjoff
        call writecurrentstate_nomasschange(outiounit,t,xi,nrj,postoid,nb)
        t_o = t
        
        print*,'t=',t,'dH/Ho=',(abs(nrjinit - nrj)/nrjinit),'nb=',nb
        
    end if
    
    ! Collision detection
    
    if (colenabled) then
        include "collisions.f90"
    end if
    
end do

write(outiounit,'(A)')    "]"
close(outiounit)
