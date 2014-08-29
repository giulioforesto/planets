! Read method coefficients
call readbutchertable(butchtablefilename,a_butch,b_butch,c_butch,ns)

! Read initial state
call readinitstate(initstatefilename,mi,xi,vi,nb)

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

allocate(kxi(nd,nb,ns))
allocate(kvi(nd,nb,ns))

allocate(xinow(nd,nb))
allocate(vinow(nd,nb))
allocate(fijnow(nd,nb,nb))

t = 0
dt = dtinit

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
    end if
    
end do

close(outiounit)
