! Paramètres

integer                 , parameter                     :: real_kind = 16    ! Precision du calcul
integer                 , parameter                     :: eftk = 4         ! Performs EFT eftk times
real (kind = real_kind) , parameter                     :: one = 1          ! Unit value in working precision
integer                 , parameter                     :: num_steps = 10   ! nombre d'étapes de la méthode

! Tableaux statiques

real (kind = real_kind) , dimension(num_steps,0:1)      :: Proots           ! 2 sets of roots for the legendre polynomials of consecutive degree
real (kind = real_kind) , dimension(num_steps)          :: Lwei             ! Weights for the gauss integration method
real (kind = real_kind) , dimension(num_steps,num_steps):: a_butch          ! Butcher a matrix of the Gauss-Legendre method
real (kind = real_kind) , dimension(num_steps)          :: b_butch,c_butch  ! Butcher b and c vectors of the Gauss-Legendre method


! Autres merdes : itérateurs, variables tests ou réutilisables 
    !Itérateurs

integer                                                 :: i,j,k,p,q                 
real (kind=real_kind)                                   :: a,b,c
