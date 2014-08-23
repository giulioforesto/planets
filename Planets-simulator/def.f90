! Paramètres

integer , parameter                                     :: real_kind = 8     ! Precision du calcul
integer , parameter                                     :: num_steps = 40    ! nombre d'étapes de la méthode

! Tableaux statiques

real (kind = real_kind) , dimension(num_steps,num_steps):: a_butch        ! Butcher a matrix of the Gauss-Legendre method
real (kind = real_kind) , dimension(num_steps)          :: b_butch,c_butch! Butcher b and c vectors of the Gauss-Legendre method



! Autres merdes : itérateurs, variables tests ou réutilisables 
    !Itérateurs

integer                                                 :: i,j,k,l,m,n,p,q                 
real (kind=real_kind)                                   :: a,b,c
real (kind=real_kind)                                   :: x(3)
