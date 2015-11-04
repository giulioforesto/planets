! Pour tous les ordres jusqu'à num_steps, la procédure exporte les tableaux de Butcher associés aux méthodes de Gauss-Legendre.

! Sets the number of threads to be created by OpenMP
!$ call omp_set_num_threads(numthreads)


Proots = 0
Pderroots = 0


call system_clock(itime1)

do i=2,num_steps

   
    print*, "Computing roots of degree",i
    
    ! Computes roots of Legendre polynomials
    
    !$omp parallel default(private) shared(Proots,i,Pderroots)
    !$omp do    

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

    !$omp end do

    !$omp barrier

    !$omp do    
    
    do j=1,i-1
        
        a = Proots(j  ,modulo(i,2))
        b = Proots(j+1,modulo(i,2))
        
        call findplegderroot_dichot(i,a,b,Pderroots(j))

    end do
    
    !$omp end do
    !$omp end parallel    

    Pderroots(0) = -1
    Pderroots(i) = 1
    
!~     print*,"P roots :"
!~     print*,Proots(1:i,modulo(i,2))
!~     
!~     print*,"Pder roots :"
!~     print*,Pderroots(1:i-1)

    ! Calcul des poids
    
    
    print*, "Computing weights"
    
    do j=1,i
        call evalpleg(i-1,Proots(j,modulo(i,2)),Legwei(j))
        Legwei(j) = i*Legwei(j)
        Legwei(j) = 2*(1 - Proots(j,modulo(i,2))*Proots(j,modulo(i,2)))/(Legwei(j)*Legwei(j))
    end do

    Lobwei(0) = 2._real_kind / (i*(i+1))
    Lobwei(i) = Lobwei(0)

    do j=1,i-1
        call evalpleg(i,Pderroots(j),Lobwei(j))
        Lobwei(j) = 2/(i*(i+1)*Lobwei(j)*Lobwei(j))
    end do

    call writegaussmeth(Proots(1:i,modulo(i,2)),Legwei(1:i),i,real_kind,"GaussLegendre")
    
    call writegaussmeth(Pderroots(0:i),Lobwei(0:i),i+1,real_kind,"GaussLobatto")

    shx(1:i) = (Proots(1:i,modulo(i,2))+1)/2        
    shw(1:i) = Legwei(1:i)/2

    do k=1,i
        do q=1,i
            if (k .ne. q) then
                invdiff(k,q) = 1/(shx(k) - shx(q))
            else
                invdiff(k,q) = 1
            end if
        end do
    end do


    if (compute_butcher) then
        
        ! Calcul de c

        print*, "Computing c"
        
        c_butch(1:i) = (Proots(1:i,modulo(i,2))+1)/2

        ! Calcul de b

        print*, "Computing b"
        
        b_butch(1:i) = Legwei(1:i)/2
        
        ! calcul de a 
        
        print*, "Computing a"
        
        ! This is the slow part. Optimized, but the algo is O(n**4), so ... very bad

        !$omp parallel default(private) firstprivate(shx,shw,i,invdiff) shared(a_butch)
        !$omp do         
        do j=1,i
            do k=1,i
                a = 0
                do p=1,i
                    c = 1
                    b = c_butch(j)*shx(p)
                    do q=1,i
                        if (k .ne. q) then
                            c = c*((b - shx(q))*invdiff(k,q))
                        end if
                    end do
                    a = a + shw(p)*c
                end do
                a_butch(j,k) = a*c_butch(j)
            end do    
        end do

        !$omp end do
        !$omp end parallel    

        call writebutchertable(a_butch(1:i,1:i),b_butch(1:i),c_butch(1:i),i,real_kind,"LegendreButcherTable")




        
        ! Calcul de c

        print*, "Computing c"
        
        c_butch(1:i) = (Pderroots(0:i)+1)/2

        ! Calcul de b

        print*, "Computing b"
        
        b_butch(1:i) = Lobwei(0:i)/2
        
        ! calcul de a 
        
        print*, "Computing a"
        
        ! This is the slow part. Optimized, but the algo is O(n**4), so ... very bad

        !$omp parallel default(private) firstprivate(shx,shw,i,invdiff) shared(a_butch)
        !$omp do         
        do j=0,i
            do k=0,i
                a = 0
                do p=1,i
                    c = 1
                    b = c_butch(j)*shx(p)
                    do q=1,i
                        if (k .ne. q) then
                            c = c*((b - shx(q))*invdiff(k,q))
                        end if
                    end do
                    a = a + shw(p)*c
                end do
                a_butch(j,k) = a*c_butch(j)
            end do    
        end do

        !$omp end do
        !$omp end parallel    

        call writebutchertable(a_butch(0:i,0:i),b_butch(0:i),c_butch(0:i),i+1,real_kind,"LobattoButcherTable")

    end if
    

    
    call system_clock(itime2)    
    print*, (itime2 - itime1)
    itime1 = itime2
    

end do



