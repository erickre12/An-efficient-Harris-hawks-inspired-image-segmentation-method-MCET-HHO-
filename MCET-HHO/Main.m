%% MCET-HHO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% An Efficient Harris Hawks-inspired Image Segmentation Method
% Erick Rodríguez-Esparza, Laura A Zanella-Calzada, Diego Oliva, Ali Asghar Heidari, 
% Daniel Zaldivar, Marco Pérez-Cisneros, Loke Kok Foong
% University of Guadalajara (UdG)

% Rodríguez-Esparza, E., Zanella-Calzada, L. A., Oliva, D., Heidari, 
% A. A., Zaldivar, D., Pérez-Cisneros, M., & Foong, L. K. (2020). 
% An Efficient Harris Hawks-inspired Image Segmentation Method. 
% Expert Systems with Applications, 113428.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
clc
close all
%% Initial data

I=imread('lena512.pgm');    % Load image
[h,nh]=imhist(I);           % Get Histogram
[m,n]=size(I);              % Image size
L=length(h);                % Lmax levels to segment 0 - 256
Nt=size(I,1) * size(I,2);   % Total pixels in the image
% Frequency distribution of each intensity level of the histogram 0 - 256
for i=1:L 
    probI(i)=h(i)/Nt;
end

%% Initial data of the HHO algorithm
nVar=2;                                 % Number of thresholds (Th)     
VarSize=[1 nVar];                       % Decision Variables in Matrix
VarMin=1;                               % Minimum value of Th
VarMax=255;                             % Maximum value of Th
%% Harris Hawks Algorithm Parameters
N=30;                                   % Maximum Number of Hawks
T=100;                                  % Maximum Number of Iterations

tic
Rabbit_Location=zeros(1,nVar);          % Initialization of the rabbit's location
Rabbit_Energy=inf;                      % Initialization of the energy of the rabbit

%% Initialization of the position of the hawks

X=initialization(N,nVar,VarMax,VarMin);

%% Harris Hawks Algorithm Main
CNVG=zeros(1,T);
t=0;                                    % Counter

while t<T
    for i=1:size(X,1)
        % Check bounds
        FU=X(i,:)>=VarMax;
        FL=X(i,:)<=VarMin;
        X(i,:)=sort(round((X(i,:).*(~(FU+FL)))+VarMax.*FU+VarMin.*FL));
        % Calculate the fitness for each hawk
        fitness=M_CEM(I,X(i,:),h);
        % Update rabbit location with the best fitness
        if fitness<Rabbit_Energy
            Rabbit_Energy=fitness;
            Rabbit_Location=X(i,:);
        end
    end
    
    E1=2*(1-(t/T)); % factor to show the decreaing energy of rabbit
    % Update the location of Harris' hawks
    for i=1:size(X,1)
        E0=2*rand()-1; %-1<E0<1
        Escaping_Energy=E1*(E0);  % escaping energy of rabbit
        
        if abs(Escaping_Energy)>=1
            %% Exploration:
            
            q=rand();
            rand_Hawk_index = floor(N*rand()+1);
            X_rand = X(rand_Hawk_index, :);
            if q<0.5
                % perch based on other family members
                X(i,:)=X_rand-rand()*abs(X_rand-2*rand()*X(i,:));
            elseif q>=0.5
                % perch on a random tall tree (random site inside group's home range)
                X(i,:)=round((Rabbit_Location(1,:)-mean(X))-rand()*((VarMax-VarMin)*rand+VarMin));
            end
            
        elseif abs(Escaping_Energy)<1
                                               
            %% Exploitation:
            
            %% phase 1: surprise pounce (seven kills)
            % surprise pounce (seven kills): multiple, short rapid dives by different hawks
            
            r=rand(); % probablity of each event
            
            if r>=0.5 && abs(Escaping_Energy)<0.5 % Hard besiege
                X(i,:)=abs((Rabbit_Location)-Escaping_Energy*abs(Rabbit_Location-X(i,:)));
            end
            
            if r>=0.5 && abs(Escaping_Energy)>=0.5  % Soft besiege
                Jump_strength=2*(1-rand()); % random jump strength of the rabbit
                X(i,:)=abs((Rabbit_Location-X(i,:))-Escaping_Energy*abs(Jump_strength*Rabbit_Location-X(i,:)));
            end
            
            %% phase 2: performing team rapid dives (leapfrog movements)
            if r<0.5 && abs(Escaping_Energy)>=0.5 % Soft besiege % rabbit try to escape by many zigzag deceptive motions
                
                %Jump_strength=2*(1-rand());
                Jump_strength=(1-rand());
                X1=abs(round(Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-X(i,:))));
                for k=1:length(X1)
                    if X1(:,k)>VarMax
                        X1(:,k)=255;
                    end
                    if X1(:,k)<VarMin
                        X1(:,k)=1;
                    end 
                end
                if M_CEM(I,X1,h)<M_CEM(I,X(i,:),h) % improved move?
                    X(i,:)=X1;
                else % hawks perform levy-based short rapid dives around the rabbit
                    X2=abs(round(Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-X(i,:))+rand(1,nVar).*Levy(nVar)));
                    for k=1:length(X2)
                        if X2(:,k)>VarMax
                            X2(:,k)=255;
                        end
                        if X2(:,k)<VarMin
                            X2(:,k)=1;
                        end 
                    end
                    if M_CEM(I,X2,h)<M_CEM(I,X(i,:),h) % improved move?
                        X(i,:)=X2;
                    end
                end
            end
            
            if r<0.5 && abs(Escaping_Energy)<0.5 % Hard besiege % rabbit try to escape by many zigzag deceptive motions
                % hawks try to decrease their average location with the rabbit
                Jump_strength=2*(1-rand());
                X1=abs(round(Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-mean(X))));
                for k=1:length(X1)
                    if X1(:,k)>VarMax
                        X1(:,k)=255;
                    end  
                    if X1(:,k)<VarMin
                        X1(:,k)=1;
                    end 
                end
                if M_CEM(I,X1,h)<M_CEM(I,X(i,:),h) % improved move?
                    X(i,:)=X1;
                else % Perform levy-based short rapid dives around the rabbit
                    X2=abs(round(Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-mean(X))+rand(1,nVar).*Levy(nVar)));
                    for k=1:length(X2)
                        if X2(:,k)>VarMax
                        X2(:,k)=255;
                        end 
                        if X2(:,k)<VarMin
                        X2(:,k)=1;
                        end   
                    end
                    if M_CEM(I,X2,h)<M_CEM(I,X(i,:),h) % improved move?
                        X(i,:)=X2;
                    end
                end
            end
        end
    end
    t=t+1;
    CNVG(t)=Rabbit_Energy;
end

%% Segmentacion de la imagen
Ith=MultiTresh(I,Rabbit_Location);
imshow(Ith)

%% Prueba la segmentacion

%PSNR: Peak Signal to Noise Ratio
PSNR=psnr(Ith, I)
% SSIM: Structural Similarity Index (1, indica una conincidencia perfecta)
SSIM=ssim(I,Ith)
%FSIM: Feature Similarity Index 
FSIM=FeatureSIM(I,Ith)

%% Histogram Plot
    fitness = Rabbit_Energy
    intensity = Rabbit_Location
    figure 
    plot(probI)
    hold on
    vmax = max(probI);
    for i = 1:length(Rabbit_Location)
        line([intensity(i), intensity(i)],[0 vmax],[1 1],'Color','r','Marker','.','LineStyle','-');
        hold on
    end
    hold off
