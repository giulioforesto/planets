! Computes the next variables

do i=1,ns
    
    xinow = 0
    vinow = 0
    fijnow = 0
    
    do j=1,i-1
        xinow = xinow + a_butch(i,j)*kxi(:,:,j)
        vinow = vinow + a_butch(i,j)*kvi(:,:,j)
    end do
    
    xinow = xi + dt*xinow
    kxi(:,:,i) = vi + dt*vinow        

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

xinow = b_butch(1)*kxi(:,:,1)
vinow = b_butch(1)*kvi(:,:,1)

do j=2,ns
    xinow = xinow + b_butch(j)*kxi(:,:,j)
    vinow = vinow + b_butch(j)*kvi(:,:,j)
end do

xi = xi + dt*xinow
vi = vi + dt*vinow
