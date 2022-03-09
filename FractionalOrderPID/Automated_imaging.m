clear all
close all
clc

%Cria diretorios onde serao salvas as imagens
mkdir ZIEGLER_E_NICHOLS
mkdir KTL_method
mkdir Kcr_Method
mkdir DE_algorithm
mkdir GA_5_algorithm
mkdir GA_2
mkdir N_M_implex
mkdir Figure_paper
path_figure_paper = 'Figure_paper';

figure_number=1;

figure(10)
to_combine = 0;
figure(11)%combine
figure(12)%combine

cd(path_figure_paper)

final=20;
dt=.1;
t=0:dt:final; % Create the ?time? vector and its increment
n=size(t);
degrau=ones(n);

P=[0.91188]; % Controller Proportional Gain
I=[0.330895]; % Integral gain of the controller
Alfa=[1.0]; % Integral Controller Expo
D=[0.628185]; % Derivative Gain of Controller
Beta=[1.0]; % Exponent Derivative Controller

k=[1]; % Plant gain
tal=[1]; % Plant Time Constant
teta=[2]; % Plant Delay


G=tf(k,[tal 1]); % Plant transfer function without delay
Greal=tf(k,[tal 1],'Inputdelay',teta); % Delayed Plant Transfer Function
Gs=pade(Greal,4); % Pade approximation
Gsfo=fotf([1 11 55 150 210 105],[5 4 3 2 1 0],[1 -10 45 -105 105],[4 3 2 1 0]);
b=[D P I]; % Create vector b
nb=[Alfa+Beta Alfa 0]; % Create the vector nb
a=[1]; % Create the vector a
na=[Alfa]; % Create the vector an
Gc=fotf(a,na,b,nb,0); % Creates the controller transfer function
S=Gc/(1+Gc*Gs); %saida do controlador
C=Gc*Gs/(1+Gc*Gs); %saida planta
W=Gsfo/(1+Gc*Gsfo); %loop do disturbio
figure(figure_number);
lsim(S,degrau,t) %saida do controlador
saideteste=step(Greal,t);
Gs1=pade(Greal,1);
saideteste2=step(Gs1,t);
Gs4=pade(Greal,4);
saideteste4=step(Gs4,t);
Gs8=pade(Greal,8);
saideteste8=step(Gs8,t);
plot(t,[saideteste saideteste2 saideteste4 saideteste8])

%insert figure things here
ax = gca;
ax.XLim = [0 8];
ax.YLim = [-0.3 2];
ax.FontSize = 12;     % set font size for axes labels
%ax.XGrid = 'on';      % draw gridlines perpendicular to x-axis
%ax.YGrid = 'on';
hTitle = title('');
hXLabel = xlabel('Time (s)');
hYLabel = ylabel('Output');
% Add legend
%hLegend = legend('');
% Adjust font
set(gca, 'FontName', 'Helvetica')
set([hTitle, hXLabel, hYLabel], 'FontName', 'AvantGarde')
%set([hLegend, gca], 'FontSize', 9)
set([hXLabel, hYLabel], 'FontSize', 12)
set(hTitle, 'FontSize', 12, 'FontWeight' , 'bold')


% Adjust axes properties
set(gca, 'Box', 'on', 'TickDir', 'in', 'TickLength', [.02 .02], ...
    'XMinorTick', 'off', 'YMinorTick', 'off', 'YGrid', 'off', 'XGrid', 'off', ...
    'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], ...
    'LineWidth', 1)
grid on
%grid minor

lgd = legend({'Original function','Pade 1 term','Pade 4 terms','Pade 8 terms'},'FontSize',9);

print(gcf,'image1.jpg','-djpeg','-r3000');

close (figure(figure_number))
figure_number = figure_number+1;
figure (figure_number)

%Make figure 2 here

rlocus(Gs4)

%insert figure things here
ax = gca;
ax.FontSize = 12;     % set font size for axes labels
%ax.XGrid = 'on';      % draw gridlines perpendicular to x-axis
%ax.YGrid = 'on';
hTitle = title('');
hXLabel = xlabel('Real Axis');
hYLabel = ylabel('Imaginary Axis');
set(gca, 'FontName', 'Helvetica')


% Adjust axes properties
set(gca, 'Box', 'on', 'TickDir', 'in', 'TickLength', [.02 .02], ...
    'XMinorTick', 'off', 'YMinorTick', 'off', 'YGrid', 'off', 'XGrid', 'off', ...
    'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], ...
    'LineWidth', 1)


print(gcf,'image2.jpg','-djpeg','-r3000');
close (figure(figure_number))
cd ../

for figure_number = 3:9

    if figure_number==3
        %ZIEGLER_E_NICHOLS
        path = 'ZIEGLER_E_NICHOLS';
        cd(path)
        P=[0.930132]; % Controller Proportional Gain
        I=[0.33219]; % Integral gain of the controller
        Alfa=[1]; % Integral Controller Expo
        D=[0.6510924]; % Derivative Gain of Controller
        Beta=[1]; % Exponent Derivative Controller

    elseif figure_number==4
        %KTL_method
        path = 'KTL_method';
        cd(path)
        P=[0.9774]; % Controller Proportional Gain
        I=[0.4235]; % Integral gain of the controller
        Alfa=[1.3353]; % Integral Controller Expo
        D=[0.4227]; % Derivative Gain of Controller
        Beta=[0.8593]; % Exponent Derivative Controller

    elseif figure_number==5
        %Kcr_Method
        path = 'Kcr_Method';
        cd(path)
        P=[1.0050]; % Controller Proportional Gain
        I=[0.4827]; % Integral gain of the controller
        Alfa=[1.3279]; % Integral Controller Expo
        D=[0.4122]; % Derivative Gain of Controller
        Beta=[0.9707]; % Exponent Derivative Controller

    elseif figure_number==6
        %DE_algorithm
        path = 'DE_algorithm';
        cd(path)
        P=[0.6016]; % Controller Proportional Gain
        I=[0.8831]; % Integral gain of the controller
        Alfa=[0.9244]; % Integral Controller Expo
        D=[1.2743]; % Derivative Gain of Controller
        Beta=[0.9964]; % Exponent Derivative Controller

    elseif figure_number==7
        %GA_5_algorith
        path = 'GA_5_algorithm';
        cd(path)
        P=[1.04]; % Controller Proportional Gain
        I=[0.494]; % Integral gain of the controller
        Alfa=[1.003]; % Integral Controller Expo
        D=[0.723]; % Derivative Gain of Controller
        Beta=[1.229]; % Exponent Derivative Controller

    elseif figure_number==8
        %GA_2
        path = 'GA_2';
        cd(path)
        P=[0.9119]; % Controller Proportional Gain
        I=[0.3309]; % Integral gain of the controller
        Alfa=[1.06]; % Integral Controller Expo
        D=[0.6282]; % Derivative Gain of Controller
        Beta=[1.29]; % Exponent Derivative Controller

    elseif figure_number==9
        %N_M_implex
        path = 'N_M_implex';
        cd(path)
        P=[0.74009]; % Controller Proportional Gain
        I=[0.39926]; % Integral gain of the controller
        Alfa=[1.0011]; % Integral Controller Expo
        D=[0.39784]; % Derivative Gain of Controller
        Beta=[1.0746]; % Exponent Derivative Controller
    end
    
    
    final=100;
    dt=.1;
    t=0:dt:final; % Create the ?time? vector and its increment
    n=size(t);
    degrau=ones(n);
    disturbio=zeros(n);
    for i=1:(final/dt)+1  
        if(i>=500) 
            disturbio(i)=1;
        else
            disturbio(i)=0;
        end
    end
    
    
    k=[1]; % Plant gain
    tal=[1]; % Plant Time Constant
    teta=[2]; % Plant Delay
    
    
    G=tf(k,[tal 1]); % Plant transfer function without delay
    Greal=tf(k,[tal 1],'Inputdelay',teta); % Delayed Plant Transfer Function
    Gs=pade(Greal,4); % Pade approximation
    Gsfo=fotf([1 11 55 150 210 105],[5 4 3 2 1 0],[1 -10 45 -105 105],[4 3 2 1 0]);
    b=[D P I]; % Create vector b
    nb=[Alfa+Beta Alfa 0]; % Create the vector nb
    a=[1]; % Create the vector a
    na=[Alfa]; % Create the vector an
    Gc=fotf(a,na,b,nb,0); % Creates the controller transfer function
    S=Gc/(1+Gc*Gs); %saida do controlador
    C=Gc*Gs/(1+Gc*Gs); %saida planta
    W=Gsfo/(1+Gc*Gsfo); %loop do disturbio
    figure(1);lsim(S,degrau,t) %saida do controlador
    
    %insert figure things here
    ax = gca;
	ax.XLim = [0 100];
	ax.YLim = [-0.3 12];
	ax.FontSize = 12;     % set font size for axes labels
	%ax.XGrid = 'on';      % draw gridlines perpendicular to x-axis
	%ax.YGrid = 'on';
	hTitle = title('');
	hXLabel = xlabel('Time (s)');
	hYLabel = ylabel('Output');
	% Add legend
	%hLegend = legend('');
	% Adjust font
	set(gca, 'FontName', 'Helvetica')
	set([hTitle, hXLabel, hYLabel], 'FontName', 'AvantGarde')
	%set([hLegend, gca], 'FontSize', 9)
	set([hXLabel, hYLabel], 'FontSize', 12)
	set(hTitle, 'FontSize', 12, 'FontWeight' , 'bold')
    
    
	% Adjust axes properties
	set(gca, 'Box', 'on', 'TickDir', 'in', 'TickLength', [.02 .02], ...
	    'XMinorTick', 'off', 'YMinorTick', 'off', 'YGrid', 'off', 'XGrid', 'off', ...
	    'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], ...
        'LineWidth', 1)
    grid on
    %grid minor
     
    print(gcf,'control_signal.jpg','-djpeg','-r3000');
    
    close(figure(1))
    
    if (k==1 && tal==1 && teta==2)
        hold on
        figure(10);lsim(C,degrau,t)
    end
    
    if (figure_number == 3)
        figure(2); %saida da planta sem disturbio
        y= lsim(C,degrau,t);
        plot (t, y,'k');
    else
        figure(2);lsim(C,degrau,t) %saida da planta sem disturbio
    end
    
    %insert figure things here
    ax = gca;
	ax.XLim = [0 50];
	ax.YLim = [-0.3 2];
	ax.FontSize = 12;     % set font size for axes labels
	%ax.XGrid = 'on';      % draw gridlines perpendicular to x-axis
	%ax.YGrid = 'on';
	hTitle = title('');
	hXLabel = xlabel('Time (s)');
	hYLabel = ylabel('Output');
	% Add legend
	%hLegend = legend('');
	% Adjust font
	set(gca, 'FontName', 'Helvetica')
	set([hTitle, hXLabel, hYLabel], 'FontName', 'AvantGarde')
	%set([hLegend, gca], 'FontSize', 9)
	set([hXLabel, hYLabel], 'FontSize', 12)
	set(hTitle, 'FontSize', 12, 'FontWeight' , 'bold')

	% Adjust axes properties
	set(gca, 'Box', 'on', 'TickDir', 'in', 'TickLength', [.02 .02], ...
	    'XMinorTick', 'off', 'YMinorTick', 'off', 'YGrid', 'off', 'XGrid', 'off', ...
	    'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], ...
        'LineWidth', 1)
    grid on
    %grid minor
    
    if (figure_number == 3)
        
        cd ../
        cd(path_figure_paper)
        image_name=['image',num2str(figure_number),'.jpg'];
        print(gcf,image_name,'-djpeg','-r3000'); 
        cd ../
        cd(path)
        
        y= lsim(C,degrau,t);
        plot (t, y,'b');
        
        %insert figure things here
        ax = gca;
        ax.XLim = [0 50];
        ax.YLim = [-0.3 2];
        ax.FontSize = 12;     % set font size for axes labels
        %ax.XGrid = 'on';      % draw gridlines perpendicular to x-axis
        %ax.YGrid = 'on';
        hTitle = title('');
        hXLabel = xlabel('Time (s)');
        hYLabel = ylabel('Output');
        % Add legend
        %hLegend = legend('');
        % Adjust font
        set(gca, 'FontName', 'Helvetica')
        set([hTitle, hXLabel, hYLabel], 'FontName', 'AvantGarde')
        %set([hLegend, gca], 'FontSize', 9)
        set([hXLabel, hYLabel], 'FontSize', 12)
        %set(hTitle, 'FontSize', 12, 'FontWeight' , 'bold')

        % Adjust axes properties
        set(gca, 'Box', 'on', 'TickDir', 'in', 'TickLength', [.02 .02], ...
            'XMinorTick', 'off', 'YMinorTick', 'off', 'YGrid', 'off', 'XGrid', 'off', ...
            'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], ...
            'LineWidth', 1)
        grid on
        %grid minor
        
    end
    
    print(gcf,'output.jpg','-djpeg','-r3000');
    
    if (figure_number ~= 3)
        hold on
        k=[1.2]; % Plant gain
        tal=[1.2]; % Plant Time Constant
        teta=[2.4]; % Plant Delay
        G=tf(k,[tal 1]); % Plant transfer function without delay
        Greal=tf(k,[tal 1],'Inputdelay',teta); % Delayed Plant Transfer Function
        Gs=pade(Greal,4); % Pade approximation
        C=Gc*Gs/(1+Gc*Gs); %saida planta
        lsim(C,degrau,t)

        k=[0.8]; % Plant gain
        tal=[0.8]; % Plant Time Constant
        teta=[1.6]; % Plant Delay
        G=tf(k,[tal 1]); % Plant transfer function without delay
        Greal=tf(k,[tal 1],'Inputdelay',teta); % Delayed Plant Transfer Function
        Gs=pade(Greal,4); % Pade approximation
        C=Gc*Gs/(1+Gc*Gs); %saida planta
        lsim(C,degrau,t)

        % Add legend
        lgd = legend({'Original','Plant +20','Plant -20'},'FontSize',9);
        
        hold off
    end
    
    if (figure_number ~= 3)
        cd ../
        cd(path_figure_paper)
        hTitle = title('');
        image_name=['image',num2str(figure_number),'.jpg'];
        print(gcf,image_name,'-djpeg','-r3000'); 
        cd ../
        cd(path)
    end
    
    k=[1]; % Plant gain
    tal=[1]; % Plant Time Constant
    teta=[2]; % Plant Delay
    G=tf(k,[tal 1]); % Plant transfer function without delay
    Greal=tf(k,[tal 1],'Inputdelay',teta); % Delayed Plant Transfer Function
    Gs=pade(Greal,4); % Pade approximation
    C=Gc*Gs/(1+Gc*Gs); %saida planta
    lsim(C,degrau,t)
    
    close(figure(2))
    
    F1= lsim(Gc,degrau,t); %saida do controlador antes do disturbio
    F = F1.'+disturbio; %soma do disturbio ao controlador antes da planta
    figure(3);lsim(W,F,t) %resultado com disturbio
    Cise=lsim(C,degrau,t);
    Fise=lsim(W,F,t);
    ISEdiferenca = dot(degrau.'-Fise,degrau.'-Fise)-dot(degrau.'-Cise,degrau.'-Cise)
    
    %insert figure things here
    ax = gca;
	ax.XLim = [0 100];
	ax.YLim = [-0.3 2];
	ax.FontSize = 12;     % set font size for axes labels
	%ax.XGrid = 'on';      % draw gridlines perpendicular to x-axis
	%ax.YGrid = 'on';
	hTitle = title('');
	hXLabel = xlabel('Time (s)');
	hYLabel = ylabel('Output');
	% Add legend
	%hLegend = legend('');
	% Adjust font
	set(gca, 'FontName', 'Helvetica')
	set([hTitle, hXLabel, hYLabel], 'FontName', 'AvantGarde')
	%set([hLegend, gca], 'FontSize', 9)
	set([hXLabel, hYLabel], 'FontSize', 12)
	set(hTitle, 'FontSize', 12, 'FontWeight' , 'bold')

	% Adjust axes properties
	set(gca, 'Box', 'on', 'TickDir', 'in', 'TickLength', [.02 .02], ...
	    'XMinorTick', 'off', 'YMinorTick', 'off', 'YGrid', 'off', 'XGrid', 'off', ...
	    'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], ...
        'LineWidth', 1)
    grid on
    %grid minor
    
    print(gcf,'output_with_disturbance.jpg','-djpeg','-r3000');
    
    cd ../
    cd(path_figure_paper)
    image_name=['image_output_with_disturbance_',path,'.jpg'];
    print(gcf,image_name,'-djpeg','-r3000');
    
    if(to_combine <=3)
        if(to_combine ~=0)
        figure(11)
        hold on
        lsim(W,F,t)
        end
        to_combine = to_combine + 1
    else
        figure(12)
        hold on
        lsim(W,F,t)
    end
    
    close(figure(3))
    
    
    cd ../
end
 cd(path_figure_paper)
 
 figure(10)
 
%insert figure things here
ax = gca;
ax.XLim = [0 50];
ax.YLim = [-0.3 2];
ax.FontSize = 12;     % set font size for axes labels
%ax.XGrid = 'on';      % draw gridlines perpendicular to x-axis
%ax.YGrid = 'on';
hTitle = title('');
hXLabel = xlabel('Time (s)');
hYLabel = ylabel('Output');
set(gca, 'FontName', 'Helvetica')
set([hTitle, hXLabel, hYLabel], 'FontName', 'AvantGarde')
%set([hLegend, gca], 'FontSize', 9)
set([hXLabel, hYLabel], 'FontSize', 12)
set(hTitle, 'FontSize', 12, 'FontWeight' , 'bold')

% Adjust axes properties
set(gca, 'Box', 'on', 'TickDir', 'in', 'TickLength', [.02 .02], ...
'XMinorTick', 'off', 'YMinorTick', 'off', 'YGrid', 'off', 'XGrid', 'off', ...
'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], ...
'LineWidth', 1)
grid on
%grid minor

% Add legend
lgd = legend({'Method Z-N','Method KTL','Method Kcr','DE algorithm','GA Optim 5 par','GA Optim 2 par','N-M Algorithm'},'FontSize',9);

print(gcf,'image10.jpg','-djpeg','-r3000');

close(figure(10))

figure(11)
 
%insert figure things here
ax = gca;
ax.XLim = [0 100];
ax.YLim = [-0.3 2];
ax.FontSize = 12;     % set font size for axes labels
%ax.XGrid = 'on';      % draw gridlines perpendicular to x-axis
%ax.YGrid = 'on';
hTitle = title('');
hXLabel = xlabel('Time (s)');
hYLabel = ylabel('Output');
set(gca, 'FontName', 'Helvetica')
set([hTitle, hXLabel, hYLabel], 'FontName', 'AvantGarde')
%set([hLegend, gca], 'FontSize', 9)
set([hXLabel, hYLabel], 'FontSize', 12)
set(hTitle, 'FontSize', 12, 'FontWeight' , 'bold')

% Adjust axes properties
set(gca, 'Box', 'on', 'TickDir', 'in', 'TickLength', [.02 .02], ...
'XMinorTick', 'off', 'YMinorTick', 'off', 'YGrid', 'off', 'XGrid', 'off', ...
'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], ...
'LineWidth', 1)
grid on
%grid minor

% Add legend
lgd = legend({'Method KTL','Method Kcr','DE algorithm'},'FontSize',9);

print(gcf,'image11.jpg','-djpeg','-r3000');

close(figure(11))

figure(12)
 
%insert figure things here
ax = gca;
ax.XLim = [0 100];
ax.YLim = [-0.3 2];
ax.FontSize = 12;     % set font size for axes labels
%ax.XGrid = 'on';      % draw gridlines perpendicular to x-axis
%ax.YGrid = 'on';
hTitle = title('');
hXLabel = xlabel('Time (s)');
hYLabel = ylabel('Output');
set(gca, 'FontName', 'Helvetica')
set([hTitle, hXLabel, hYLabel], 'FontName', 'AvantGarde')
%set([hLegend, gca], 'FontSize', 9)
set([hXLabel, hYLabel], 'FontSize', 12)
set(hTitle, 'FontSize', 12, 'FontWeight' , 'bold')

% Adjust axes properties
set(gca, 'Box', 'on', 'TickDir', 'in', 'TickLength', [.02 .02], ...
'XMinorTick', 'off', 'YMinorTick', 'off', 'YGrid', 'off', 'XGrid', 'off', ...
'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], ...
'LineWidth', 1)
grid on
%grid minor

% Add legend
lgd = legend({'GA Optim 5 par','GA Optim 2 par','N-M Algorithm'},'FontSize',9);

print(gcf,'image12.jpg','-djpeg','-r3000');

close(figure(12))

cd ../
