%To run this matlab script you need to fill the empty [] with the desired values
clear all
final=[20]; %Simulation time (in seconds)
dt=.1; %time increment
t=0:dt:final; % Create the ?time? vector
n=size(t); 
degrau=ones(n); %create a step at 0 seconds
%code to create the disturbance
for i=1:(final/dt)+1
    if(i>=500) %define when the disturbance step will happens in unit of (1s/10)
        disturbance(i)=1;
    else
        disturbance(i)=0;
    end
end
%Plant Definitions
k=[1]; %Plant gain
tal=[1]; %Plant Time Constant
teta=[2]; %Plant Delay
G=tf(k,[tal 1]); %Plant transfer function without delay
Greal=tf(k,[tal 1], 'inputdelay',teta); % Delayed Plant Transfer Function 
Gs=pade(Greal,4); %Pade approximation
Gsfo=fotf([1 11 55 150 210 105],[5 4 3 2 1 0],[1 -10 45 -105 105],[4 3 2 1 0]); %plade aproximation rewriten in FONCOM language
%Controller definitions
P=[0.91188]; %Controller Proportional Gain
I=[0.330895]; % Integral gain of the controller
Alfa=[1]; %Integral Controller Expo
D=[0.628185]; % Derivative Gain of Controller
Beta=[1]; % Exponent Derivative Controller
b=[D P I]; % Create vector b
nb=[Alfa+Beta Alfa 0]; % Create the vector nb
a=[1]; %Create the vector a
na=[Alfa]; % Create the vector an
Gc=fotf(a,na,b,nb,0); % Creates the controller transfer function with FOMCON
S=Gc/(1+Gc*Gs); %control loop
C=Gc*Gs/(1+Gc*Gs); %system loop
W=Gsfo/(1+Gc*Gsfo); %disturbance loop
F1= lsim(Gc,degrau,t); %control signal before disturbance
F = F1.'+disturbance; %sum of disturbanc to the control signal
figure(1);lsim(S,degrau,t) %Plot control signal
figure(2);lsim(C,degrau,t) %Plot system signal without disturbance
figure(3);lsim(W,F,t) %Plot system signal with disturbance
%Calculation of comparison criteria
Cise=lsim(C,degrau,t); %system signal without disturbance
Fise=lsim(W,F,t); %system signal with disturbance
ISEdiferenca = 0.1*(dot(degrau.'-Fise,degrau.'-Fise) - dot(degrau.'-Cise,degrau.'-Cise)) %relative disturbance ISE