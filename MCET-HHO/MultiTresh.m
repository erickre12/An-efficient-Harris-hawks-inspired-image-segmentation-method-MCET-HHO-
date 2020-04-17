function Ith=MultiTresh(I,Th)
    [m,n]=size(I);
    limites=[0 Th 255];
    Ith(:,:)=I*0;
    k=1;
    for i= 1:m
        for j=1:n
            while(k<size(limites,2))
                if(I(i,j)>=limites(1,k) && I(i,j)<=limites(1,k+1))
                    Ith(i,j,1)=limites(1,k);
                end
                k=k+1;
            end
            k=1;
        end
    end
end