%To run this matlab script you need to fill the empty [] with the desired values

clear all %  Initialization  
clc %  Initialization  

final=[]; %Simulation time (in seconds)
dt=.1; %time increment
t=0:dt:final; % Create the ?time? vector
%Plant Definitions
k=[]; %Plant gain
tal=[]; %Plant Time Constant
teta=[]; %Plant Delay
G=tf(k,[tal 1]); %Plant transfer function without delay
Greal=tf(k,[tal 1], 'inputdelay',teta); % Delayed Plant Transfer Function 
Gs=pade(Greal,4); %Pade approximation

iteramax = 1000;  %  Maximum number of times to execute the DE algorithm  
VALORINI = 50;  %  Random value to start the algorithm, well above the expected value of "ITAE"  
ITAEBEST = VALORINI;  %  Initial value of ITAE  
for itera = 1: iteramax %  Beginning of the runs of the DE algorithm  
    D = 5;  %$  Number of Variables
    objf=inline('abs((x1+(x2/(-0.4 + 0.5457i)^x3)+x4* (-0.4+0.5457i)^x5)* (1/(0.6+0.5457i))+1)^2 + angle((x1+(x2/(-0.4+0.5457i)^x3)+x4* (-0.4+0.5457i)^x5)*(1/(0.6+0.5457i))+1)^2', 'x1','x2','x3','x4','x5');%  Function to be minimized  
    objf = vectorize (objf);  %  Function to be minimized vectorized  
    %  starting the DE parameters  
    N = 100;  %  Population  
    itmax = 100;  %  Maximum number of iterations  
    CR = 0.6;  % Cross-Over Frequency  
    %  F = 0.5;  % Fixed mutation frequency  
    % Limits of the problem  
    a(1: N, 1) = [0]; b (1: N, 1) = [50];  %  Limits of the variable P (x1)  
    a(1: N, 2) = [0]; b (1: N, 2) = [25];  %  Limits of variable I (x2)  
    a(1: N, 3) = [0]; b (1: N, 3) = [2];  %  Limits of the alpha variable (x3)  
    a(1: N, 4) = [0]; b (1: N, 4) = [25];  %  Limits of variable D (x4)  
    a(1: N, 5) = [0]; b (1: N, 5) = [2];  %  Limits of the beta variable (x5)  
    d = (b-a); 
    basemat=repmat(int16(linspace(1,N,N)),N,1);
    basej = repmat (int16 (linspace (1, D, D)), N, 1);  %$  Used for parameters j  
    x=a+d.*rand(N,D);  %$  Random initialization of positions from mutation type 1  
    fx=objf(x(:,1),x(:,2),x(:,3),x(:,4),x(:,5)); %$  Evaluation objective for all parameters  
    [fxbest, ixbest] = min (fx);  %$  Selecting the best  
    xbest = x (ixbest, 1: D); 
    for it = 1: itmax;  %  Initiation of iterations  
        permat=bsxfun(@(x,y) x(randperm(y(1))),basemat',N(ones(N,1)))'; 
        F=0.4+rand(1,1)*0.6;  %  Variable frequency of mutation  
        v(1:N,1:D)=abs(repmat(xbest,N,1)+F * (x(permat(1:N,1), 1:D)-x(permat(1:N,2), 1:D)));  %  Donor vector generator for mutation  
        r = repmat (randi ([1 D], N, 1), 1, D);  %$  Recombination  
        muv = ((rand(N,D)<CR) + (basej==r)) ~= 0;  %$  Crossing  
        mux = 1-muv;  %$  Crossing  
        u(1:N,1:D)=x(1:N,1:D).*mux(1:N,1:D)+ v(1:N,1:D).*muv(1:N,1:D);  %$  Creation of vector u  
        fu=objf(u(:,1),u(:,2),u(:,3),u(:,4),u(:,5));  %$  Function for selection  
        idx = fu <fx;  %$  Selection  
        fx(idx)=fu(idx);  %$  Selection  
        x (idx, 1: D) = u (idx, 1: D);  %$  Selection  
        [fxbest, ixbest] = min (fx);  %$  Choosing the Best  
        xbest = x (ixbest, 1: D);  %$  Choosing the best vector  
    end %  End of iterations  
    [xbest fxbest];  %  best values for the variables and for the function  
    % Calculation of the values to find the ITAE  
    kp4=xbest(1);  
    ki4=xbest(2);
    alpha4=xbest(3); 
    kd4=xbest(4);
    beta4=xbest(5);
    b4=[kd4 kp4 ki4];
    nb4=[alpha4+beta4 alpha4 0]; 
    a4=[1];  
    na4=[alpha4];
    Gc4=fotf(a4,na4,b4,nb4);  
    Ft4=Gc4*Gs;
    h4=feedback(Ft4,1); 
    output4 = step(h4, t); 
    ITAEDE=t*abs(1-output4)*0.1;  %$  ITAE calculated with the best values  
    if  (ITAEDE <ITAEBEST) %$  Comparison of ITAE's  
        ITAEBEST = ITAEDE %$  Definition of the new ITAE  
        xbesto = xbest %$  Definition of the new parameters  
    end  
end  
[ITAEBEST, xbesto] %$  Best values found  