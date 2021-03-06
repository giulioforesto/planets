! Detects and deals with collisions

!~ call compute_energy(mi,xi,vi,nb,nrj)

! Computes all distances

k=0
do while (k<nb-1)
    k=k+1
    l=k
    do while (l<nb)
        l=l+1
        dxnow = xi(:,l) - xi(:,k)
        dxnow2 = dxnow(1)*dxnow(1)
        do p=2,nd
            dxnow2 = dxnow2 + dxnow(p)*dxnow(p)
        end do
        
        if (dxnow2 < dx2min) then
            
            call compute_energy(mi,xi,vi,nb,nrj)
            
            ! Averages velocities and position, sums mass

            xi(:,k) = (mi(k)*xi(:,k) + mi(l)*xi(:,l))/(mi(k) + mi(l))
            vi(:,k) = (mi(k)*vi(:,k) + mi(l)*vi(:,l))/(mi(k) + mi(l))
            mi(k) = mi(k) + mi(l)

            postoid(k) = currentid
            currentid = currentid + 1

            ! Creates backup

            allocate(mib(nb-1))
            allocate(xib(nd,nb-1))
            allocate(vib(nd,nb-1))
            allocate(postoidb(nb-1))
            
            if (useeft) then
                allocate(xieftb(nd,nb-1))
                allocate(vieftb(nd,nb-1))
            end if

            do p=1,l-1
                mib(p) = mi(p)
                xib(:,p) = xi(:,p)
                vib(:,p) = vi(:,p)
                postoidb(p) = postoid(p)
                if (useeft) then
                    xieftb(:,p) = xieft(:,p)
                    vieftb(:,p) = vieft(:,p)
                end if
            end do
            do p=l+1,nb
                mib(p-1) = mi(p)
                xib(:,p-1) = xi(:,p)
                vib(:,p-1) = vi(:,p)
                postoidb(p-1) = postoid(p)
                if (useeft) then
                    xieftb(:,p-1) = xieft(:,p)
                    vieftb(:,p-1) = vieft(:,p)
                end if
            end do

            ! Two planets have fused

            nb = nb - 1

            ! Deallocation of arrays

            deallocate(mi)
            deallocate(xi)
            deallocate(vi)
            
            deallocate(postoid)
            deallocate(fijnow)
            deallocate(xinow)
            deallocate(kxi)
            deallocate(kvi)
            deallocate(vinow)
            
            if (useeft) then
                deallocate(vieft)
                deallocate(xieft)
            end if
                        
            if (.not. explicitRK) then
                deallocate(zxi0)    
                deallocate(zxi1)
                deallocate(zxi2)    
            end if

            ! Reallocation of arrays
            
            allocate(postoid(nb))
            allocate(fijnow(nd,nb,nb))
            allocate(xinow(nd,nb))
            allocate(kxi(nd,nb,ns))
            allocate(kvi(nd,nb,ns))
            allocate(vinow(nd,nb))
            
            if (useeft) then
                allocate(xieft(nd,nb))
                allocate(vieft(nd,nb))
            end if

            if (.not. explicitRK) then
                allocate(zxi0(nd,nb,ns))    
                allocate(zxi1(nd,nb,ns))
                allocate(zxi2(nd,nb,ns))    
            end if
            
            ! Copy backup            
            
            mi = mib
            xi = xib
            vi = vib
            postoid = postoidb
            
            if (useeft) then
                xieft = xieftb
                vieft = vieftb
            end if
            
            deallocate(mib)
            deallocate(xib)
            deallocate(vib)
            deallocate(postoidb)
            
            if (useeft) then
                deallocate(xieftb)
                deallocate(vieftb)
            end if
            
            ! Write state to output file
            
            call compute_energy(mi,xi,vi,nb,nrjnew)
            
            nrjoff = nrjoff  + nrj - nrjnew
            
            call writeinitstate(outiounit,t,mi,xi,vi,nrj,postoid,nb)

        end if
        
    end do
end do
