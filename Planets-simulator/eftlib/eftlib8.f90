module eftlib8

    integer                     , parameter :: real_kind_eft = 8        ! Precision du calcul
    real(kind = real_kind_eft)  , parameter :: one = 1
    
contains

    include "functions_eft.f90"

end module
