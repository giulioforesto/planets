! Solves the implicit Runge-Kutta Equations for the next variables 

do i=1,ns
    zxi0(:,:,i) = c_butch(i)*vi
end do
zxi0 = dt * zxi0

!~ zxi1 = zxi0
zxi1 = 0

implcvgd = .false.

nit = 0

do while (.not. implcvgd )
    
    ! zxi1 => zxi2
    
    do i=1,ns
        xinow = xi + zxi1(:,:,i)
        
        do k=1,nb-1
            do l=k,nb
                dxnow = xinow(:,l) - xinow(:,k)
                dxnow2 = dxnow(1)*dxnow(1)
                do p=2,nd
                    dxnow2 = dxnow2 + dxnow(p)*dxnow(p)
                end do
                fijnow(:,k,l) = Guniv * dxnow * (dxnow2 ** ( (fpow-2)/2 ) )
            end do
        end do
        
        do k=1,nb
            dvnow = 0
            do l=1,k-1
                dvnow = dvnow - mi(l) * fijnow(:,l,k)
            end do
            do l=k+1,nb
                dvnow = dvnow + mi(l) * fijnow(:,k,l)
            end do
            kvi(:,k,i) = dvnow
        end do    
    end do
        
    do i=1,ns
        kdvi(:,:,i) = a_butch2(i,1)*kvi(:,:,1)
        do j=2,ns
            kdvi(:,:,i) = kdvi(:,:,i) + a_butch2(i,j)*kvi(:,:,j)
        end do
    end do
    
    zxi2 = zxi0 + dt2 * kdvi
    
    ! zxi2 => zxi1
    
    do i=1,ns
        xinow = xi + zxi2(:,:,i)
        
        do k=1,nb-1
            do l=k,nb
                dxnow = xinow(:,l) - xinow(:,k)
                dxnow2 = dxnow(1)*dxnow(1)
                do p=2,nd
                    dxnow2 = dxnow2 + dxnow(p)*dxnow(p)
                end do
                fijnow(:,k,l) = Guniv * dxnow * (dxnow2 ** ( (fpow-2)/2 ) )
            end do
        end do
        
        do k=1,nb
            dvnow = 0
            do l=1,k-1
                dvnow = dvnow - mi(l) * fijnow(:,l,k)
            end do
            do l=k+1,nb
                dvnow = dvnow + mi(l) * fijnow(:,k,l)
            end do
            kvi(:,k,i) = dvnow
        end do    
    end do
        
    do i=1,ns
        kdvi(:,:,i) = a_butch2(i,1)*kvi(:,:,1)
        do j=2,ns
            kdvi(:,:,i) = kdvi(:,:,i) + a_butch2(i,j)*kvi(:,:,j)
        end do
    end do
    
    zxi1 = zxi0 + dt2 * kdvi

    ! Has it converged ?
    
    kdvi = abs(zxi1-zxi2)
    
    errsum = 0
    
    do i=1,ns
        do j=1,nb
            do k=1,nd
                errsum = errsum + kdvi(k,j,i)  
            end do
        end do
    end do

    nit = nit + 1
    
    implcvgd = (( errsum <  errsummax ) .or. ( nit > maxit ))

end do

! Computes kvi and kxi from zxi1


do i=1,ns

    xinow = xi + zxi1(:,:,i)

    do k=1,nb-1
        do l=k,nb
            dxnow = xinow(:,l) - xinow(:,k)
            dxnow2 = dxnow(1)*dxnow(1)
            do p=2,nd
                dxnow2 = dxnow2 + dxnow(p)*dxnow(p)
            end do
            fijnow(:,k,l) = Guniv * dxnow * (dxnow2 ** ( (fpow-2)/2 ) )
        end do
    end do

    do k=1,nb
        dvnow = 0
        do l=1,k-1
            dvnow = dvnow - mi(l) * fijnow(:,l,k)
        end do
        do l=k+1,nb
            dvnow = dvnow + mi(l) * fijnow(:,k,l)
        end do
        kvi(:,k,i) = dvnow
    end do    

end do

do i=1,ns
    vinow = a_butch(i,1)*kvi(:,:,1)
    do j=2,ns
        vinow = vinow + a_butch(i,j)*kvi(:,:,j)
    end do
    kxi(:,:,i) = vi + dt*vinow        
end do


xinow = b_butch(1)*kxi(:,:,1)
vinow = b_butch(1)*kvi(:,:,1)

do j=2,ns
    xinow = xinow + b_butch(j)*kxi(:,:,j)
    vinow = vinow + b_butch(j)*kvi(:,:,j)
end do

xi = xi + dt*xinow
vi = vi + dt*vinow




