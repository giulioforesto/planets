! This function is the potential energy between two unit mass bodies with normalized units (Guniv == 1).
! Its argument is the SQUARED distance.
pure function potential(x2) result(f)

    real(kind=real_kind)    , intent(in)    :: x2
    real(kind=real_kind)                    :: f
    
    f = (x2 ** ( (fpow)/2 ) ) / fpow
    
end function


! This function is a normalized force over the distance
! Warning : for the model to be consistent, the force should be minus the derivative of the potential. 
pure function forceoverdist(x2) result(f) 
    real(kind=real_kind)    , intent(in)    :: x2
    real(kind=real_kind)                    :: f
    
    f = (x2 ** ( (fpow-2)/2 ) )
    
end function
!~ 
!~ 
!~ !-----------------------------------------------------------------------------------------------------------------
!~ ! Attraction + repulsion
!~ !-----------------------------------------------------------------------------------------------------------------
!~ 
!~ ! This function is the potential energy between two unit mass bodies with normalized units (Guniv == 1).
!~ ! Its argument is the SQUARED distance.
!~ pure function potential(x2) result(f)
!~ 
!~     real(kind=real_kind)    , intent(in)    :: x2
!~     real(kind=real_kind)                    :: f
!~     
!~     f = (x2 ** ( (fpowatt)/2 ) ) / fpowatt - repcoeff *(x2 ** ( (fpowrep)/2 ) ) / (fpowrep)
!~     
!~ end function
!~ 
!~ 
!~ ! This function is a normalized force over the distance
!~ ! Warning : for the model to be consistent, the force should be minus the derivative of the potential. 
!~ pure function forceoverdist(x2) result(f) 
!~     real(kind=real_kind)    , intent(in)    :: x2
!~     real(kind=real_kind)                    :: f
!~     
!~     f = (x2 ** ( (fpowatt-2)/2 ) ) - repcoeff * (x2 ** ( (fpowrep-2)/2 ) )
!~     
!~ end function
!~ 
