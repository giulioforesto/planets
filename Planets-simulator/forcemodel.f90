pure function forceoverdist(x2) result(f)
    real(kind=real_kind)    , intent(in)    :: x2
    real(kind=real_kind)                    :: f
    
    f = -(x2 ** ( (fpow-2)/2 ) )
    
end function

pure function potential(x2) result(f)

    real(kind=real_kind)    , intent(in)    :: x2
    real(kind=real_kind)                    :: f
    
    f = (x2 ** ( (fpow)/2 ) ) / fpow
    
end function
