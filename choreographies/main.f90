! Fortran 90 program searching for periodic N-body movements.

program main
    
    ! Links with OpenMP if available
    !$ use OMP_LIB

    implicit none

    include 'def.f90'
    include 'prog.f90'

contains

    include 'iofunctions.f90'
    include 'functions.f90'
    include 'forcemodel.f90'

end program main

