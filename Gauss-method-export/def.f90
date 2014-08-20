! Paramètres

integer , parameter                                     :: real_kind = 8       ! Precision du calcul
integer , parameter                                     :: num_steps = 200      ! nombre d'étapes de la méthode

! Tableaux statiques

real (kind = real_kind) , dimension(0:num_steps,0:2)    :: Pleg           ! 3 Legendre polynomials of consecutive degree
real (kind = real_kind) , dimension(num_steps,0:1)      :: Proots         ! 2 sets of roots for the legendre polynomials of consecutive degree
real (kind = real_kind) , dimension(num_steps)          :: Lwei         ! Weights for the gauss integration method
real (kind = real_kind) , dimension(num_steps,num_steps):: a_butch        ! Butcher a matrix of the Gauss-Legendre method
real (kind = real_kind) , dimension(num_steps,num_steps):: a_test        ! Butcher a matrix of the Gauss-Legendre method
real (kind = real_kind) , dimension(num_steps)          :: b_butch,c_butch! Butcher b and c vectors of the Gauss-Legendre method

real(kind=real_kind)    , dimension(num_steps,num_steps):: mat
real(kind=real_kind)    , dimension(num_steps)          :: vec




! Autres merdes : itérateurs, variables tests ou réutilisables 
    !Itérateurs

integer                                                 :: i,j,k,l,m,n,p,q                 
real(kind=real_kind)                                    :: a,b,c
real(kind=real_kind)                                    :: x(3)
