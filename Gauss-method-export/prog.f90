! Pour tous les ordres jusqu'à num_steps, la procédure exporte les tableaux de Butcher associés aux méthodes de Gauss-Legendre.

Proots = 0

do i=2,num_steps
    
    print*, "Computing roots of degree",i
    
    ! Computes roots of Legendre polynomials
    
    do j=1,i
        if (j .eq. 1) then
            a = real(-1,real_kind)
            b = Proots(1,modulo(i-1,2))
        else if (j .eq. i) then
            a = Proots(i-1,modulo(i-1,2))
            b = real(1,real_kind)
        else
            a = Proots(j-1,modulo(i-1,2))
            b = Proots(j  ,modulo(i-1,2))
        end if
        
        call findplegroot_dichot(i,a,b,Proots(j,modulo(i,2)))

    end do
    
    ! Calcul des poids
    
    print*, "Computing weights"
    
    do j=1,i
        call evalpleg(i-1,Proots(j,modulo(i,2)),Lwei(j))
        Lwei(j) = i*Lwei(j)
        Lwei(j) = 2*(1 - Proots(j,modulo(i,2))*Proots(j,modulo(i,2)))/(Lwei(j)*Lwei(j))
    end do
    
    ! Calcul de c

    print*, "Computing c"
    
    c_butch(1:i) = (Proots(1:i,modulo(i,2))+1)/2

    ! Calcul de b

    print*, "Computing b"
    
    b_butch(1:i) = Lwei(1:i)/2
    
    ! calcul de a 
    
    print*, "Computing a"
    
    ! This is the slow part. Optimized, but the algo is O(n**4), so ... very bad
    
    do j=1,i
        do k=1,i
            a = 0
            do p=1,i
                c = 1
                b = c_butch(j)*c_butch(p)
                do q=1,i
                    if (k .ne. q) then
                        c = c*((b - c_butch(q))/(c_butch(k) - c_butch(q)))
                    end if
                end do
                a = a + b_butch(p)*c
            end do
            a_butch(j,k) = a*c_butch(j)
        end do    
    end do
    
    ! Export des résultats

    print*, "Exporting"
    
    call writebutchertable(a_butch(1:i,1:i),b_butch(1:i),c_butch(1:i),i,real_kind)
    call writegaussmeth(Proots(1:i,modulo(i,2)),Lwei(1:i),i,real_kind)

end do
