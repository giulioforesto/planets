! Paramètres

integer                 , parameter                     :: real_kind = 8        ! Precision du calcul
integer                 , parameter                     :: numthreads = 1       ! Number of CPU threads to be used by OpenMP

integer                 , parameter                     :: nd = 2               ! Number of simulated space dimensions
character(len=*)        , parameter                     :: gaussmethfilename = &
!~     './input/methods/gauss_int_meth  2prec16.txt'
    './input/methods/1pt.txt'
character(len=*)        , parameter                     :: fourrierimportcoefffilename = &
    './input/init_states/test_cycle.txt'
character(len=*)        , parameter                     :: fourrierexportcoefffilename = &
    './output/test_cycle_export.txt'
character(len=*)        , parameter                     :: exportinitstatefilename = &
    './output/initstateconverged.txt'
    
real (kind = real_kind) , parameter                     :: pi = &
    3.141592653589793238462643383279502884197169399375105820974944_16              ! Pi
real (kind = real_kind) , parameter                     :: Guniv = 1            ! Universal gravitational constant
real (kind = real_kind) , parameter                     :: fpow = -1            ! Power in force potential law

integer                 , parameter                     :: maxnfinit = 1                    ! Maximum number of fourier coefficients to be randomly initialized.
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

real(kind=real_kind)                                            :: nran                 ! Random number
real(kind=real_kind)                                            :: act                 ! Value of action

integer                                                 :: i,j,k,l
