! Read method coefficients
call readbutchertable(butchtablefilename,a_butch,b_butch,c_butch,ns)

! Read initial state
call readinitstate(initstatefilename,mi,xi,vi,nb)

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
dt = dtinit


allocate(fijnow(nd,nb,nb))
allocate(xinow(nd,nb))
allocate(kxi(nd,nb,ns))
allocate(kvi(nd,nb,ns))
allocate(vinow(nd,nb))

if (.not. explicitRK) then
    
    dt2 = dt*dt
    
    allocate(a_butch2(ns,ns))
    a_butch2 = matmul(a_butch,a_butch)

    allocate(zxi0(nd,nb,ns))    
    allocate(zxi1(nd,nb,ns))
    allocate(zxi2(nd,nb,ns))    

    allocate(kdvi(nd,nb,ns))
    
end if

! Write initial state in output file

t_o = 0
open(unit = outiounit, file = trim(outputfilename), access='sequential', action='write',position='rewind')

call writeinitstate(outiounit,t,mi,xi,nb,nd)

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
    
    t = t + dt
    
    ! Write output
    
    if (t > t_o + dto) then
        call writetoend_currentstate_nomasschange(outiounit,t,xi,nb,nd)
        t_o = t
        
        print*,'t=',t
        
    end if
    
    
end do

close(outiounit)
