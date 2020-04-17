function [u] = miu(a,b,h)
    sumH=0;
    sumL=0;
    for i=a:b-1
        sumH=i*h(i) + sumH;
        sumL=h(i) + sumL;
    end
    if (sumH==0 && sumL==0)
        u=0;
    else
        u=sumH/sumL;
    end
end