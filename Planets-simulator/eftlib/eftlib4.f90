module eftlib4

    integer                     , parameter :: real_kind_eft = 4        ! Precision du calcul
    real(kind = real_kind_eft)  , parameter :: one = 1
    
contains

    include "functions_eft.f90"

end module
