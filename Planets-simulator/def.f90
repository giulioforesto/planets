! Paramètres

integer                 , parameter                     :: real_kind = 8        ! Precision du calcul

character(len=*)        , parameter                     :: butchtablefilename = &
    './input/methods/explicit/kutta_3_8th_table.txt'
logical                 , parameter                     :: explicitRK = .true.  ! If true then the method is treated as expicit, if false, then the method is treated as implicit.
integer                 , parameter                     :: nd = 2               ! Number of simulated space dimensions
real (kind = real_kind) , parameter                     :: dtinit = 1d-2        ! Inital time step

logical                 , parameter                     :: centerinit = .true.  ! Centers barycenter to origin
character(len=*)        , parameter                     :: initstatefilename = &
    './input/init_states/init_test.txt'
character(len=*)        , parameter                     :: outputfilename = &
    './output/outfile.txt'
real (kind = real_kind) , parameter                     :: Guniv = 1            ! Universal gravitational constant
real (kind = real_kind) , parameter                     :: fpow = -1            ! Power in force law

real (kind = real_kind) , parameter                     :: tf = 100              ! End of simulation time
real (kind = real_kind) , parameter                     :: dto = 0.1            ! Output time step
integer                 , parameter                     :: outiounit = 3        ! Unit of output for json file


! Tableaux statiques

real (kind = real_kind) , dimension(nd)                     :: xmoy,vmoy        ! Initial mean position and velocity
real (kind = real_kind) , dimension(nd)                     :: dxnow,dvnow            ! Distance / length increment / velocity increment between two bodies

! Tableaux dynamiques & variables

real (kind = real_kind) , allocatable   , dimension(:,:)    :: a_butch          ! Butcher a matrix
real (kind = real_kind) , allocatable   , dimension(:)      :: b_butch,c_butch  ! Butcher b and c vectors
integer                                                     :: ns               ! Number of stages of the Runge-Kutta method

real (kind = real_kind) , allocatable   , dimension(:)      :: mi               ! Masses of bodies
real (kind = real_kind) , allocatable   , dimension(:,:)    :: xi,vi            ! Positions and velocities of bodies
integer                                                     :: nb               ! Number of bodies

real (kind = real_kind) , allocatable   , dimension(:,:,:)  :: kxi,kvi          ! Intermediate Runge-Kutta stages for positions and velocities
real (kind = real_kind) , allocatable   , dimension(:,:)    :: xinow,vinow      ! Intermediate position and velocity
real (kind = real_kind) , allocatable   , dimension(:,:,:)  :: fijnow           ! Intermediate reciprocal forces 


real (kind = real_kind)                                     :: t,dt             ! Current time and time step
real (kind = real_kind)                                     :: t_o              ! Last output time
real (kind = real_kind)                                     :: mtot             ! Total mass of the system
real (kind = real_kind)                                     :: dxnow2           ! Square distance between two bodies

! Autres merdes : itérateurs, variables tests ou réutilisables 
    !Itérateurs

integer                                                 :: i,j,k,l,m,n,p,q                 
real (kind=real_kind)                                   :: a,b,c
real (kind=real_kind)                                   :: x(3)
