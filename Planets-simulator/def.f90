! Paramètres

integer                 , parameter                     :: real_kind = 8        ! Precision du calcul

character(len=*)        , parameter                     :: butchtablefilename = &
    './input/methods/explicit/kutta_3_8th_table.txt'
logical                 , parameter                     :: explicitRK = .true.  ! If true then the method is treated as expicit, if false, then the method is treated as implicit.
integer                 , parameter                     :: nd = 2               ! Number of simulated space dimensions
real (kind = real_kind) , parameter                     :: dtinit = 0.01        ! Inital time step

character(len=*)        , parameter                     :: initstatefilename = &
    './input/init_states/init_test.txt'
character(len=*)        , parameter                     :: outputfilename = &
    './output/outfile.txt'
real (kind = real_kind) , parameter                     :: Guniv = 1            ! Universal gravitational constant
real (kind = real_kind) , parameter                     :: fpow = 2             ! Power in force law

real (kind = real_kind) , parameter                     :: tf = 10              ! End of simulation time
real (kind = real_kind) , parameter                     :: dto = 0.1            ! Output time step
integer                 , parameter                     :: outiounit = 3        ! Unit of output for json file


! Tableaux statiques

! Tableaux dynamiques & variables

real (kind = real_kind) , allocatable   , dimension(:,:)    :: a_butch          ! Butcher a matrix
real (kind = real_kind) , allocatable   , dimension(:)      :: b_butch,c_butch  ! Butcher b and c vectors
integer                                                     :: ns               ! Number of stages of the Runge-Kutta method

real (kind = real_kind) , allocatable   , dimension(:)      :: mi               ! Masses of bodies
real (kind = real_kind) , allocatable   , dimension(:,:)    :: xi,vi            ! Positions and velocities of bodies
integer                                                     :: nb               ! Number of bodies

real (kind = real_kind) , allocatable   , dimension(:,:,:)  :: kxi,kvi          ! Intermediate Runge-Kutta stages for positions and velocities

real (kind = real_kind)                                     :: t,dt             ! Current time and time step
real (kind = real_kind)                                     :: t_o              ! Last output time

! Autres merdes : itérateurs, variables tests ou réutilisables 
    !Itérateurs

integer                                                 :: i,j,k,l,m,n,p,q                 
real (kind=real_kind)                                   :: a,b,c
real (kind=real_kind)                                   :: x(3)
