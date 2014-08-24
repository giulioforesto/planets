! Read method coefficients
call readbutchertable(butchtablefilename,a_butch,b_butch,c_butch,ns)

! Read initial state
call readinitstate(initstatefilename,mi,xi,vi,nb)

! Set memory and variables up

allocate(kxi(nd,nb,ns))
allocate(kvi(nd,nb,ns))

t = 0
dt = dtinit

! Write initial state in output file

t_o = 0
open(unit = outiounit, file = trim(outputfilename))

call writeinitstate(outiounit,t,mi,xi,nb,nd)

t=2

call writecurrentstate_nomasschange(outiounit,t,xi,nb,nd)

!~ do while (t < tf)

!~ end do

close(outiounit)
