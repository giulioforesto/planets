! Paramètres

integer                 , parameter                     :: real_kind = 16   ! Precision du calcul
integer                 , parameter                     :: numthreads = 8   ! Number of CPU threads to be used by OpenMP
integer                 , parameter                     :: eftk = 0         ! Performs EFT eftk times
real (kind = real_kind) , parameter                     :: one = 1          ! Unit value in working precision
integer                 , parameter                     :: num_steps = 3 ! nombre d'étapes de la méthode
logical                 , parameter                     :: compute_butcher = .true. ! Compute the associated Butcher tableau

! Tableaux statiques

real (kind = real_kind) , dimension(num_steps,0:1)      :: Proots           ! 2 sets of roots for the legendre polynomials of consecutive degree
real (kind = real_kind) , dimension(0:num_steps)        :: Pderroots        ! 1 set of roots for the legendre polynomials derivative
real (kind = real_kind) , dimension(num_steps)          :: Legwei           ! Weights for the Gauss Legendre integration method
real (kind = real_kind) , dimension(0:num_steps)        :: Lobwei           ! Weights for the Gauss Lobatto integration method
real (kind = real_kind) , dimension(0:num_steps,0:num_steps):: a_butch          ! Butcher a matrix of the Gauss-Legendre method
real (kind = real_kind) , dimension(0:num_steps,0:num_steps):: invdiff
real (kind = real_kind) , dimension(0:num_steps)        :: b_butch,c_butch  ! Butcher b and c vectors of the Gauss-Legendre method
real (kind = real_kind) , dimension(num_steps)          :: shx,shw          ! Shifted Gauss Legendre integration nodes and weights on [0,1]


! Autres merdes : itérateurs, variables tests ou réutilisables 
    !Itérateurs

integer                                                 :: i,j,k,p,q,itime1,itime2                 
real (kind=real_kind)                                   :: a,b,c,d

