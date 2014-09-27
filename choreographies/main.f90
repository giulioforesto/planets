! Fortran 90 program searching for periodic N-body movements.

program main
    
    ! Links with OpenMP if available
    !$ use OMP_LIB
    use eftlib8

    implicit none

    include 'def.f90'
    include 'prog.f90'

contains

    include 'functions.f90'

end program main

