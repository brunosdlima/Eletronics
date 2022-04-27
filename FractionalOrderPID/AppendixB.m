%To run this script you first need to run Appendix A
D=5; %  Number of Variables 
objf=inline('abs((x1+(x2/(-0.4+0.5457i)^x3)+ x4*(-0.4+0.5457i)^x5)*(1/(0.6+0.5457i))+1)^2 +angle((x1+(x2/(-0.4+0.5457i)^x3)+ x4*(-0.4+0.5457i)^x5)*(1/(0.6+0.5457i))+1)^2' ,'x1','x2','x3','x4','x5');objf = vectorize (objf); %  Function to be minimized vectorized 
objf=vectorize(objf); %  Function to be minimized vectorized vectorized
N = 50; %  population 
itmax = 200; %  number of maximum iterations 
CR = 0.5; %  Frequency of cross-over 
a(1:N,1)=[0] ; b(1:N,1)=[50]; %  Limits of the variable P (x1) 
a(1:N,2)=[0] ; b(1:N,2)=[25]; %  Limits of the variable I (x2) 
a(1:N,3)=[0] ; b(1:N,3)=[2]; %  Limits of the alpha variable (x3) 
a(1:N,4)=[0] ; b(1:N,4)=[25]; %  Limits of the variable D (x4) 
a(1:N,5)=[0] ; b(1:N,5)=[2]; %  Limits of the beta variable (x5) 
d=(b-a); %  Limits of the problem 
basemat=repmat(int16(linspace(1,N,N)),N,1);
basej=repmat(int16(linspace(1,D,D)),N,1);  %  Used for parameters j 
x=a+d.*rand(N,D); %  Random initialization of positions from mutation type 1  
fx=objf(x(:,1),x(:,2),x(:,3),x(:,4),x(:,5)); %$  Evaluation objective for all parameters  
[fxbest, ixbest] = min (fx); %  Selecting the best 
xbest = x (ixbest, 1: D); 
for it = 1: itmax;  %  Initiation of iterations 
    permat=bsxfun(@(x,y) x(randperm(y(1))),basemat',N(ones(N,1)))'; 
    F=0.4+rand(1,1)*0.6;  %  Variable frequency of mutation  
    v(1:N,1:D)=abs(repmat(xbest,N,1)+F * (x(permat(1:N,1), 1:D)-x(permat(1:N,2), 1:D)));  %  Donor vector generator for mutation  
    r = repmat (randi ([1 D], N, 1), 1, D);  %$  Recombination  
    muv = ((rand(N,D)<CR) + (basej==r)) ~= 0;  %$  Crossing  
    mux = 1-muv;  %$  Crossing  
    u(1:N,1:D)=x(1:N,1:D).*mux(1:N,1:D)+ v(1:N,1:D).*muv(1:N,1:D);  %$  Creation of vector u  
    fu = objf (u (:, 1), u (:, 2), u (:, 3), u (:, 4), u (:, 5)); %  Function for selection 
    idx = fu <fx;  %  Selection 
    fx (idx) = fu (idx); %  Selection 
    x (idx, 1: D) = u (idx, 1: D); %  Selection 
    [fxbest, ixbest] = min (fx); %  Choosing the Best 
    xbest = x (ixbest, 1: D); %  Choosing the Best 
end %  End of iterations 
[xbest fxbest]; %  Reveals the best values for the variables and for the objective function.