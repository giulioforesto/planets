! Paramètres

integer                 , parameter                     :: real_kind = 8        ! Precision du calcul
integer                 , parameter                     :: numthreads = 1       ! Number of CPU threads to be used by OpenMP

integer                 , parameter                     :: nd = 2               ! Number of simulated space dimensions
character(len=*)        , parameter                     :: gaussmethfilename = &
    './input/methods/gauss_int_meth300prec16.txt'
!~     './input/methods/gauss_int_meth900prec16.txt'
!~     './input/methods/1pt.txt'
character(len=*)        , parameter                     :: fourrierimportcoefffilename = &
    './input/init_states/test_cycle.txt'
character(len=*)        , parameter                     :: fourrierexportcoefffilename = &
    './output/test_cycle_export.txt'
character(len=*)        , parameter                     :: exportinitstatefilename = &
    './output/initstateconverged.txt'
character(len=*)        , parameter                     :: exportcheattrajfilename = &
    './output/cheattrajconverged.txt'
logical                 , parameter                     :: restartfromlast = .false.
!~ logical                 , parameter                     :: restartfromlast = .true.

    
real (kind = real_kind) , parameter                     :: pi = &
    3.141592653589793238462643383279502884197169399375105820974944_16           ! Pi
real (kind = real_kind) , parameter                     :: gold = &
    1.618033988749894848204586834365638117720309179805762862135448_16           ! Golden ratio
real (kind = real_kind) , parameter                     :: invgold = &
    0.618033988749894848204586834365638117720309179805762862135448_16           ! Inverse of golden ratio
real (kind = real_kind) , parameter                     :: Guniv = 1            ! Universal gravitational constant
real (kind = real_kind) , parameter                     :: fpow = -1            ! Power in force potential law

integer                 , parameter                     :: maxnfinit = 1000                 ! Maximum number of fourier coefficients to be randomly initialized.
logical                 , parameter                     :: disturbfouriercoeffs = .false.   ! Randomizes arround initial Fourier coefficients
real(kind=real_kind)    , parameter                     :: disturbcoeff = 0.1_8

integer                                                         :: nc                   ! Number of cycle
real(kind=real_kind)    , dimension(:)  ,allocatable            :: mc                   ! Mass of all bodies on a given cycle
integer                 , dimension(:)  ,allocatable            :: nb                   ! Number of bodies on cycle
integer                                                         :: maxnb                ! Maximum number of bodies on cycle
integer                 , dimension(:)  ,allocatable            :: nf                   ! Degree of trigonometric polynomial describing cycles
integer                                                         :: maxnf                ! Maximum degree of trigonometric polynomial describing cycles

integer                                                         :: si                   ! Number of steps of integration method
real(kind=real_kind)    , dimension(:)  ,allocatable            :: xi,wi                ! abscisse and weights of integration method
real(kind=real_kind)    , dimension(:,:,:,:)    , allocatable   :: abf
real(kind=real_kind)    , dimension(:,:,:,:,:)  , allocatable   :: sincostable

integer                 , parameter                             :: nminopt = 50         ! Minumum number of optimisation steps
integer                 , parameter                             :: nmaxopt = 500          ! Maximum number of optimisation steps
integer                                                         :: iopt              ! Current number of optimisation steps
integer                                                         :: nlin              ! Current number of line search
real(kind =real_kind)   , parameter                             :: distiniini = 1d-4     ! Size of initial optimisation step
real(kind =real_kind)   , parameter                             :: distmin = 1d-12       ! Minimum size of optimisation step
real(kind =real_kind)   , parameter                             :: distmax = 1d-1         ! Maximum size of optimisation step
real(kind =real_kind)   , parameter                             :: convratio = 1d3       ! Size of final optimisation step
logical                                                         :: computedg

real(kind =real_kind)   , parameter                             :: ninfmax = 1d-5         ! Maximum value of norm of gradient of action
real(kind =real_kind)   , parameter                             :: n1max   = 1d-4         ! Maximum value of norm of gradient of action
real(kind =real_kind)   , parameter                             :: n2max   = 1d-4         ! Maximum value of norm of gradient of action

real(kind=real_kind)                                            :: nran                 ! Random number
real(kind=real_kind)                                            :: act,actnew                  ! Value of action
real(kind=real_kind)    , dimension(:,:,:,:)    , allocatable   :: gradact              ! Value of gradient of action
real(kind=real_kind)    , dimension(:,:,:,:)    , allocatable   :: gradactdf              ! Value of gradient of action
real(kind=real_kind)    , dimension(:,:,:,:)    , allocatable   :: gradactd              ! Value of gradient of action
real(kind=real_kind)    , dimension(:,:,:,:)    , allocatable   :: gradactnew              ! Value of gradient of action
real(kind=real_kind)                                            :: ninf,n1,n2           ! Norms of gradient of action

real(kind=real_kind)                                            :: actg,actm,actm2,actd
real(kind=real_kind)                                            :: distg,distm,distm2,distd
real(kind=real_kind)    , dimension(:,:,:,:)    , allocatable   :: abfs


integer                                                 :: i,j,k,l
real(kind=real_kind)                                    :: alpha, distini
