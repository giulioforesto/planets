! Paramètres

integer                 , parameter                     :: real_kind = 8        ! Precision du calcul
integer                 , parameter                     :: numthreads = 1       ! Number of CPU threads to be used by OpenMP
character(len=*)        , parameter                     :: butchtablefilename = &
    './input/methods/implicit/gauss_butch_table 20prec16.txt'
!~     './input/methods/explicit/kutta_3_8th_table.txt'
logical                 , parameter                     :: explicitRK = .false. ! If true then the method is treated as expicit, if false, then the method is treated as implicit.
real (kind = real_kind) , parameter                     :: errsummax = 1d-17    ! Maximum difference between two iterations of implicit method
integer                 , parameter                     :: maxit = 10           ! Maximum number of iterations in the implicit system

logical                 , parameter                     :: useeft = .true. ! Uses error-free transformations for compensated summations

integer                 , parameter                     :: nd = 2               ! Number of simulated space dimensions
real (kind = real_kind) , parameter                     :: dtinit = 0.0001_16        ! Inital time step

logical                 , parameter                     :: centerinit = .true.  ! Centers barycenter to origin
logical                 , parameter                     :: loadinitstate = .true. ! Loads initial state from file or creates a random one
integer                 , parameter                     :: nbinit = 50          ! Initial number of bodies to create.
real (kind = real_kind) , parameter                     :: xmaxinit = 5         ! Initial size of box containing all randomly created bodies
real (kind = real_kind) , parameter                     :: vmeaninit = 0        ! Initial mean velocity
real (kind = real_kind) , parameter                     :: mmaxinit = 1         ! Maximum initial mass
character(len=*)        , parameter                     :: initstatefilename = &
!~     './input/init_states/init_test_crash.txt'
    './input/init_states/initstateconverged.txt'
character(len=*)        , parameter                     :: outputfilename = &
    './output/outfile.txt'
real (kind = real_kind) , parameter                     :: Guniv = 1                 ! Universal gravitational constant
real (kind = real_kind) , parameter                     :: pi = &
    3.141592653589793238462643383279502884197169399375105820974944_16              ! Pi
real (kind = real_kind) , parameter                     :: fpow = -1            ! Power in force law
real (kind = real_kind) , parameter                     :: fpowatt = 2            ! Attraction power in force law
real (kind = real_kind) , parameter                     :: fpowrep = -1            ! Repulsion power in force law
real (kind = real_kind) , parameter                     :: repcoeff = 1            ! Repulsion coefficient
logical                 , parameter                     :: colenabled = .true.   ! Turns collision model on or off
real (kind = real_kind) , parameter                     :: dx2min = 1d-3       ! Minimum square distance before collision

real (kind = real_kind) , parameter                     :: tf = 100             ! End of simulation time
real (kind = real_kind) , parameter                     :: dto = 1d-2 - 1d-6           ! Output time step
integer                 , parameter                     :: outiounit = 3        ! Unit of output for json file

! Tableaux statiques

real (kind = real_kind) , dimension(nd)                 :: xmoy,vmoy        ! Mean position and velocity
real (kind = real_kind) , dimension(nd)                 :: dxnow,dvnow      ! Distance / length increment / velocity increment between two bodies

! Tableaux dynamiques & variables

real (kind = real_kind) , allocatable   , dimension(:,:)    :: a_butch, a_butch2! Butcher a matrix and its square
real (kind = real_kind) , allocatable   , dimension(:)      :: b_butch, c_butch ! Butcher b and c vectors
integer                                                     :: ns               ! Number of stages of the Runge-Kutta method

real (kind = real_kind) , allocatable   , dimension(:)      :: mi               ! Masses of bodies
real (kind = real_kind) , allocatable   , dimension(:,:)    :: xi,vi            ! Positions and velocities of bodies
integer                                                     :: nb               ! Number of bodies
integer                 , allocatable   , dimension(:)      :: postoid, postoidb! Position of bodies in the arrays => Unique ID number
integer                                                     :: currentid
real (kind = real_kind) , allocatable   , dimension(:,:,:)  :: kxi,kvi          ! Intermediate Runge-Kutta stages for positions and velocities
real (kind = real_kind) , allocatable   , dimension(:,:,:)  :: zxi0,zxi1,zxi2   ! Intermediate implicit Runge-Kutta stages for positions and velocities
real (kind = real_kind) , allocatable   , dimension(:,:)    :: xinow,vinow      ! Intermediate position and velocity
real (kind = real_kind) , allocatable   , dimension(:,:)    :: xieft,vieft      ! Residual position and velocity for compensated EFT operations
real (kind = real_kind) , allocatable   , dimension(:,:,:)  :: fijnow           ! Intermediate reciprocal forces 

logical                                                     :: implcvgd         ! Convergence of implicit iterations
integer                                                     :: nit              ! Number of implicit iterations

real (kind = real_kind)                                     :: t,dt,dt2         ! Current time, time step and squared time step
real (kind = real_kind)                                     :: teft             ! Residual time for compensated EFT operations
real (kind = real_kind)                                     :: t_o              ! Last output time
real (kind = real_kind)                                     :: mtot             ! Total mass of the system
real (kind = real_kind)                                     :: dxnow2           ! Square distance between two bodies
real (kind = real_kind)                                     :: errsum           ! Difference between two implicit iterations

real (kind = real_kind) , allocatable   , dimension(:)      :: mib              ! Mass buffer in case of collision
real (kind = real_kind) , allocatable   , dimension(:,:)    :: xib,vib          ! Position and velocity buffers in case of collision
real (kind = real_kind) , allocatable   , dimension(:,:)    :: xieftb,vieftb    ! Position and velocity residuals buffers in case of collision

real (kind = real_kind)                                     :: nran             ! Random number
real (kind = real_kind)                                     :: nrj, nrjoff , nrjnew ! Energies
real (kind = real_kind)                                     :: nrjinit ! Energies


! Autres merdes : itérateurs, variables tests ou réutilisables 
    !Itérateurs

integer                                                 :: i,j,k,l,m,n,p,q                 
real (kind=real_kind)                                   :: a,b,c
real (kind=real_kind)                                   :: x(3)
