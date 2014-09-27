! Paramètres

integer                 , parameter                     :: real_kind = 8        ! Precision du calcul
integer                 , parameter                     :: numthreads = 1       ! Number of CPU threads to be used by OpenMP
character(len=*)        , parameter                     :: gaussmethfilename = &
    './input/methods/implicit/gauss_butch_table 10prec16.txt'

integer                 , parameter                     :: nd = 2               ! Number of simulated space dimensions




integer                                                 :: nc                   ! Number of cycle
integer , dimension(:)                                  :: nb                   ! Number of bodies on cycle
integer , dimension(:)                                  :: nf                   ! Degree of trigonometric polynomial describing cycles

integer                                                 :: si                   ! Number of steps of integration method
real    (kind=real_kind)    , dimension(:)              :: xi,wi                ! abscisse and weights of integration method
