% this program computes the minimum cross entropy for an image based in
% some threshold values.
% 
% close all
% clear all
% 
% I = imread('test2.jpg');
% h = imhist(I);
% T = [117];

%I -> Gray Scale Image
%h ->histogram
%T -> Thresholds


function [Dt] = M_CEM(I,Th,h)
    %normalize the histogram ==>  hn(k)=h(k)/(n*m) ==> k  in [1 256]
    [n,m] = size(I);
    hn = h /(n * m);
    %compute miu values
    for ii=1:length(Th)+1
        m1=0;
        m2=0;
        if ii==1
            v1=1;
            v2=Th(ii)-1;
        elseif ii==(length(Th)+1)
            v1=Th(ii-1);
            v2=256;
        else
            v1=Th(ii-1);
            v2=Th(ii)-1;
        end
               
        for i=v1:v2  % miu from 1 to tn
            m1 = m1 + (i * hn(i));
            m2 = m2 + hn(i);
        end

        if m2 == 0
            miu(ii)=m1/(m2+eps);
        else
            miu(ii)=m1/m2;
        end
    
        %compute each entropy according the thresholds
        Entro = double(0);
        for i = v1:v2 
            if miu(ii) == 0
                Entro = double(Entro + (i * hn(i) * log(miu(ii) + eps)));
            else
                Entro = double(Entro + (i * hn(i) * log(miu(ii))));
            end
        end
        Entropy(ii) = Entro;     
    end
    %entropy of gray level image   1-> L  (L = 256)
    imEntropy = double(0);
    for i = 1:256
        imEntropy = double(imEntropy+(i*hn(i)*log(i)));
    end
    
    %Compute the summatory Dt = entropy of image - entropy1 - entropy2...
    Entemp=0;
    for i =1: length(Entropy)
        Entemp = Entemp + Entropy(i);
    end
Dt = imEntropy - Entemp;
end







