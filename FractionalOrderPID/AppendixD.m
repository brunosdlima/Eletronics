%To run this script you first need to run "optimtool" from "Global optimization toolbox" 
%Select ga-Genetic Algorithm and define number of variables as the number of unknwon variables to be optimized, in this case 5
%Fill the bounds with [0 0 0 0 0] and [100 50 2 50 2]
%Set options as "Default" or "Constraint dependent"
%In Fitness function add the name of the function. Example "AppendixD"

function J = funcao(x)
    t=0:0.1:50;   %Create the Vector Time  
    v = zeros(length(t), 1);
    v(:)=0.1; %Create vector t' for calculation of evaluation criteria
    k=1;   %Gain of plant  
    tal=1;   %Plant time constant  
    theta=2;   %Delay of plant  
    Greal=tf(k,[tal 1],'inputdelay',theta); %Plant Transfer Function  
    Gs=pade(Greal,4);   %Pade approximation  
    b=[x(4) x(1) x(2)];   %Create the 'b'  
    nb=[x(5)+x(3) x(3) 0];   %Create the 'nb'  
    a=1;   %Create the 'a'  
    na=x(3);   %Create the 'na'  
    Gc=fotf(a,na,b,nb);   %Controller transfer function  
    Ft=Gc*Gs;   %System transfer function (plant + controller)  
    h=feedback(Ft, 1);   %Closed loop system  
    output=step(h, t);   %Applies a step input to the system in closed loop  
    J=0.001*dot((1-output), (1-output))*0.1+0.999*dot(v,abs(1-output))   %J function  