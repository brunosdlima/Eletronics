%This script simulates a robot arm consisted of 3 four bar linakge. Three
%different modules are available. If the variable video is set to 1, a
%video with the possible position will be shown. If the variable image is
%set to 1, an image will be generated with the possible positions marked as
%red '*'. If position is set to 1 a desired position will be required and 
%the algorithm will calculate the necessary angles to achieve this position.
%The parameters below 'Adjust this values to the robot arm' must be changed
%for parameters of the robot arm currently in study.

clear all
clc

video=0;     %Plays a video with the movement of the arm
image=1;     %Generates an image with possible locations of the grip
position=0;  %Generates an image with a close position to the required one

%Adjust this values to the robot arm
%****************************************************************************************************************************
%Maximum and minimum angles for the engines
theta_M1_max=deg2rad(110);
theta_M1_min=deg2rad(70);
theta_M2_max=deg2rad(200);
theta_M2_min=deg2rad(130);

%Lenght of each link
le=35;      %vertical drive arm
lc=80;      %link
la=80;      %forward drive arm
lf=35;      %left piece of horizontal arm
li=80;      %right piece of horizontal arm
ld=40;      %left part of triangular link
lh=20;      %right part of triangular link
lg=46.25;   %upper part of triangular link
lb=40;      %link attached to base
lj=20;      %grid attachment link
lk=45.2355; %link to point of griping

%Predefined angles
theta1=deg2rad(25.5);      %Angle between P1 and P2 and ground
theta37=deg2rad(95);       %Angle between P4 and P3 and P7
theta810=deg2rad(13.42);   %Angle between P9 and P8 and P10

%Initial position of motor angle
theta_M1=deg2rad(110);  %Engine controlling forward drive arm
theta_M2=deg2rad(180);  %Engine controlling vertical drive arm

%Tolerance to find an specific point
search_point_tolerance=0.001;  %Actual tolerance
max_search_loops=7;            %Number of loops of search
%****************************************************************************************************************************

%****************************************************************************************************************************
%Visualizing movement
if video
    changing_mov=1;
    for(theta_M1 = theta_M1_min:0.05:theta_M1_max)
        if changing_mov
            for(theta_M2 = theta_M2_min:0.05:theta_M2_max)
            P1=[0,0];
            P2=[-lb*cos(theta1),lb*sin(theta1)];
            P3=[la*cos(theta_M1),la*sin(theta_M1)];

            % %Intermediate calculus for P4
            XB_rot=(P2(1)-P1(1))*cos(theta_M1)+(P2(2)-P1(2))*sin(theta_M1);
            YB_rot=-(P2(1)-P1(1))*sin(theta_M1)+(P2(2)-P1(2))*cos(theta_M1);

            f=sqrt(((la-XB_rot)*(la-XB_rot))+((YB_rot)*(YB_rot)));
            beta=acos(((lb*lb)-(lc*lc)+(f*f))/(2*lb*f));
            gamma=atan2((YB_rot),(la-XB_rot));
            theta134=deg2rad(180)-gamma-beta;
            P4=P3 + ld * [cos(theta134+theta_M1),sin(theta134+theta_M1)];

            P5=[le*cos(theta_M2),le*sin(theta_M2)];

            % %Intermediate calculus for P6
            XB_rot=(P5(1)-P1(1))*cos(theta_M1)+(P5(2)-P1(2))*sin(theta_M1);
            YB_rot=-(P5(1)-P1(1))*sin(theta_M1)+(P5(2)-P1(2))*cos(theta_M1);

            f=sqrt(((la-XB_rot)*(la-XB_rot))+((YB_rot)*(YB_rot)));
            beta=acos(((le*le)-(lc*lc)+(f*f))/(2*le*f));
            gamma=atan2((YB_rot),(la-XB_rot));
            theta136=deg2rad(180)-gamma-beta;
            P6=P3 + lf * [cos(theta136+theta_M1),sin(theta136+theta_M1)];

            theta34=atan2((P4(2)-P3(2)),(P3(1)-P4(1)));
            P7=P3 + lj * [cos(pi-theta34-theta37),sin(pi-theta34-theta37)];
            theta68=atan2((P3(2)-P6(2)),(P3(1)-P6(1)));
            P8=P6 + (lf+li) * [cos(theta68),sin(theta68)];

            % %Intermediate calculus for P9
            XB_rot=(P7(1)-P3(1))*cos(theta68)+(P7(2)-P3(2))*sin(theta68);
            YB_rot=-(P7(1)-P3(1))*sin(theta68)+(P7(2)-P3(2))*cos(theta68);

            f=sqrt(((li-XB_rot)*(li-XB_rot))+((YB_rot)*(YB_rot)));
            beta=acos(((lj*lj)-(lc*lc)+(f*f))/(2*lj*f));
            gamma=atan2((YB_rot),(li-XB_rot));
            theta389=deg2rad(180)-gamma-beta;

            P9=P8 + lj * [cos(theta389),sin(theta389)];

            theta89=atan2((P8(1)-P9(1)),(P9(2)-P8(2)));
            P10=P8 + lk * [cos(theta810+theta89),sin(theta810+theta89)];

            %Plotting the current position
            plot([P1(1) P3(1)],[P1(2) P3(2)]);
            hold on;
            fill([-15 15 21 -21],[0 0 -15 -15],'k');
            plot([P1(1) P2(1) P4(1) P3(1)],[P1(2) P2(2) P4(2) P3(2)]);
            plot([P1(1) P5(1) P6(1) P3(1)],[P1(2) P5(2) P6(2) P3(2)]);
            fill([P3(1) P4(1) P7(1)],[P3(2) P4(2) P7(2)],'g');
            plot([P3(1) P7(1) P9(1) P8(1) P3(1)],[P3(2) P7(2) P9(2) P8(2) P3(2)]);
            plot(P10(1),P10(2),'*','Color',[1 0 0]);
            fill([P8(1) P9(1) P10(1)],[P8(2) P9(2) P10(2)],'b');
            axis ([-60 160 -20 160]);
            axis('square');
            hold on;
            pause(eps);
            hold off;
            end
            changing_mov=0;
        else
            for(theta_M2 = theta_M2_max:-0.05:theta_M2_min)
            P1=[0,0];
            P2=[-lb*cos(theta1),lb*sin(theta1)];
            P3=[la*cos(theta_M1),la*sin(theta_M1)];

            % %Intermediate calculus for P4
            XB_rot=(P2(1)-P1(1))*cos(theta_M1)+(P2(2)-P1(2))*sin(theta_M1);
            YB_rot=-(P2(1)-P1(1))*sin(theta_M1)+(P2(2)-P1(2))*cos(theta_M1);

            f=sqrt(((la-XB_rot)*(la-XB_rot))+((YB_rot)*(YB_rot)));
            beta=acos(((lb*lb)-(lc*lc)+(f*f))/(2*lb*f));
            gamma=atan2((YB_rot),(la-XB_rot));
            theta134=deg2rad(180)-gamma-beta;
            P4=P3 + ld * [cos(theta134+theta_M1),sin(theta134+theta_M1)];

            P5=[le*cos(theta_M2),le*sin(theta_M2)];

            % %Intermediate calculus for P6
            XB_rot=(P5(1)-P1(1))*cos(theta_M1)+(P5(2)-P1(2))*sin(theta_M1);
            YB_rot=-(P5(1)-P1(1))*sin(theta_M1)+(P5(2)-P1(2))*cos(theta_M1);

            f=sqrt(((la-XB_rot)*(la-XB_rot))+((YB_rot)*(YB_rot)));
            beta=acos(((le*le)-(lc*lc)+(f*f))/(2*le*f));
            gamma=atan2((YB_rot),(la-XB_rot));
            theta136=deg2rad(180)-gamma-beta;
            P6=P3 + lf * [cos(theta136+theta_M1),sin(theta136+theta_M1)];

            theta34=atan2((P4(2)-P3(2)),(P3(1)-P4(1)));
            P7=P3 + lj * [cos(pi-theta34-theta37),sin(pi-theta34-theta37)];
            theta68=atan2((P3(2)-P6(2)),(P3(1)-P6(1)));
            P8=P6 + (lf+li) * [cos(theta68),sin(theta68)];

            % %Intermediate calculus for P9
            XB_rot=(P7(1)-P3(1))*cos(theta68)+(P7(2)-P3(2))*sin(theta68);
            YB_rot=-(P7(1)-P3(1))*sin(theta68)+(P7(2)-P3(2))*cos(theta68);

            f=sqrt(((li-XB_rot)*(li-XB_rot))+((YB_rot)*(YB_rot)));
            beta=acos(((lj*lj)-(lc*lc)+(f*f))/(2*lj*f));
            gamma=atan2((YB_rot),(li-XB_rot));
            theta389=deg2rad(180)-gamma-beta;

            P9=P8 + lj * [cos(theta389),sin(theta389)];

            theta89=atan2((P8(1)-P9(1)),(P9(2)-P8(2)));
            P10=P8 + lk * [cos(theta810+theta89),sin(theta810+theta89)];

            %Plotting the current position
            plot([P1(1) P3(1)],[P1(2) P3(2)]);
            hold on;
            fill([-15 15 21 -21],[0 0 -15 -15],'k');
            plot([P1(1) P2(1) P4(1) P3(1)],[P1(2) P2(2) P4(2) P3(2)]);
            plot([P1(1) P5(1) P6(1) P3(1)],[P1(2) P5(2) P6(2) P3(2)]);
            fill([P3(1) P4(1) P7(1)],[P3(2) P4(2) P7(2)],'g');
            plot([P3(1) P7(1) P9(1) P8(1) P3(1)],[P3(2) P7(2) P9(2) P8(2) P3(2)]);
            plot(P10(1),P10(2),'*','Color',[1 0 0]);
            fill([P8(1) P9(1) P10(1)],[P8(2) P9(2) P10(2)],'b');
            axis ([-60 160 -20 160]);
            axis('square');
            hold on;
            pause(eps);
            hold off;
            end
            changing_mov=1;
        end
    end
end

%****************************************************************************************************************************
%Searching specific position
if position
    xvalue = 'Type the x coordinate of the grip: ';
    xvalue = input(xvalue);
    yvalue = 'Type the y coordinate of the grip: ';
    yvalue = input(yvalue);
    P10_desired(1)=xvalue;
    P10_desired(2)=yvalue;
    
    P1=[0,0];
    P2=[-lb*cos(theta1),lb*sin(theta1)];
    P3=[la*cos(theta_M1),la*sin(theta_M1)];

    %Intermediate calculus for P4
    XB_rot=(P2(1)-P1(1))*cos(theta_M1)+(P2(2)-P1(2))*sin(theta_M1);
    YB_rot=-(P2(1)-P1(1))*sin(theta_M1)+(P2(2)-P1(2))*cos(theta_M1);

    f=sqrt(((la-XB_rot)*(la-XB_rot))+((YB_rot)*(YB_rot)));
    beta=acos(((lb*lb)-(lc*lc)+(f*f))/(2*lb*f));
    gamma=atan2((YB_rot),(la-XB_rot));
    theta134=deg2rad(180)-gamma-beta;
    P4=P3 + ld * [cos(theta134+theta_M1),sin(theta134+theta_M1)];

    P5=[le*cos(theta_M2),le*sin(theta_M2)];

    %Intermediate calculus for P6
    XB_rot=(P5(1)-P1(1))*cos(theta_M1)+(P5(2)-P1(2))*sin(theta_M1);
    YB_rot=-(P5(1)-P1(1))*sin(theta_M1)+(P5(2)-P1(2))*cos(theta_M1);

    f=sqrt(((la-XB_rot)*(la-XB_rot))+((YB_rot)*(YB_rot)));
    beta=acos(((le*le)-(lc*lc)+(f*f))/(2*le*f));
    gamma=atan2((YB_rot),(la-XB_rot));
    theta136=deg2rad(180)-gamma-beta;
    P6=P3 + lf * [cos(theta136+theta_M1),sin(theta136+theta_M1)];

    theta34=atan2((P4(2)-P3(2)),(P3(1)-P4(1)));
    P7=P3 + lj * [cos(pi-theta34-theta37),sin(pi-theta34-theta37)];
    theta68=atan2((P3(2)-P6(2)),(P3(1)-P6(1)));
    P8=P6 + (lf+li) * [cos(theta68),sin(theta68)];

    %Intermediate calculus for P9
    XB_rot=(P7(1)-P3(1))*cos(theta68)+(P7(2)-P3(2))*sin(theta68);
    YB_rot=-(P7(1)-P3(1))*sin(theta68)+(P7(2)-P3(2))*cos(theta68);

    f=sqrt(((li-XB_rot)*(li-XB_rot))+((YB_rot)*(YB_rot)));
    beta=acos(((lj*lj)-(lc*lc)+(f*f))/(2*lj*f));
    gamma=atan2((YB_rot),(li-XB_rot));
    theta389=deg2rad(180)-gamma-beta;

    P9=P8 + lj * [cos(theta389),sin(theta389)];

    theta89=atan2((P8(1)-P9(1)),(P9(2)-P8(2)));
    P10=P8 + lk * [cos(theta810+theta89),sin(theta810+theta89)];
    
    dbetweenvec=sqrt(((P10_desired(1)-P10(1))*(P10_desired(1)-P10(1)))+((P10_desired(2)-P10(2))*(P10_desired(2)-P10(2))));
    dbetweenvec_achieved=dbetweenvec;
    P10_achieved=P10;
    theta_M1_min_i=theta_M1_min;
    theta_M1_max_i=theta_M1_max;
    theta_M2_min_i=theta_M2_min;
    theta_M2_max_i=theta_M2_max;
    pace=1;
    out_range_it=0;
    while(dbetweenvec>search_point_tolerance)
        pace=pace/10;
        for(theta_M1 = theta_M1_min_i:pace:theta_M1_max_i)
            for(theta_M2 = theta_M2_min_i:pace:theta_M2_max_i)
                P1=[0,0];
                P2=[-lb*cos(theta1),lb*sin(theta1)];
                P3=[la*cos(theta_M1),la*sin(theta_M1)];

                % %Intermediate calculus for P4
                XB_rot=(P2(1)-P1(1))*cos(theta_M1)+(P2(2)-P1(2))*sin(theta_M1);
                YB_rot=-(P2(1)-P1(1))*sin(theta_M1)+(P2(2)-P1(2))*cos(theta_M1);

                f=sqrt(((la-XB_rot)*(la-XB_rot))+((YB_rot)*(YB_rot)));
                beta=acos(((lb*lb)-(lc*lc)+(f*f))/(2*lb*f));
                gamma=atan2((YB_rot),(la-XB_rot));
                theta134=deg2rad(180)-gamma-beta;
                P4=P3 + ld * [cos(theta134+theta_M1),sin(theta134+theta_M1)];

                P5=[le*cos(theta_M2),le*sin(theta_M2)];

                % %Intermediate calculus for P6
                XB_rot=(P5(1)-P1(1))*cos(theta_M1)+(P5(2)-P1(2))*sin(theta_M1);
                YB_rot=-(P5(1)-P1(1))*sin(theta_M1)+(P5(2)-P1(2))*cos(theta_M1);

                f=sqrt(((la-XB_rot)*(la-XB_rot))+((YB_rot)*(YB_rot)));
                beta=acos(((le*le)-(lc*lc)+(f*f))/(2*le*f));
                gamma=atan2((YB_rot),(la-XB_rot));
                theta136=deg2rad(180)-gamma-beta;
                P6=P3 + lf * [cos(theta136+theta_M1),sin(theta136+theta_M1)];

                theta34=atan2((P4(2)-P3(2)),(P3(1)-P4(1)));
                P7=P3 + lj * [cos(pi-theta34-theta37),sin(pi-theta34-theta37)];
                theta68=atan2((P3(2)-P6(2)),(P3(1)-P6(1)));
                P8=P6 + (lf+li) * [cos(theta68),sin(theta68)];

                % %Intermediate calculus for P9
                XB_rot=(P7(1)-P3(1))*cos(theta68)+(P7(2)-P3(2))*sin(theta68);
                YB_rot=-(P7(1)-P3(1))*sin(theta68)+(P7(2)-P3(2))*cos(theta68);

                f=sqrt(((li-XB_rot)*(li-XB_rot))+((YB_rot)*(YB_rot)));
                beta=acos(((lj*lj)-(lc*lc)+(f*f))/(2*lj*f));
                gamma=atan2((YB_rot),(li-XB_rot));
                theta389=deg2rad(180)-gamma-beta;

                P9=P8 + lj * [cos(theta389),sin(theta389)];

                theta89=atan2((P8(1)-P9(1)),(P9(2)-P8(2)));
                P10=P8 + lk * [cos(theta810+theta89),sin(theta810+theta89)];

                dbetweenvec=sqrt(((P10_desired(1)-P10(1))*(P10_desired(1)-P10(1)))+((P10_desired(2)-P10(2))*(P10_desired(2)-P10(2))));

                if dbetweenvec<dbetweenvec_achieved
                    dbetweenvec_achieved=dbetweenvec;
                    P10_achieved=P10;
                    theta_M1_achieved=theta_M1;
                    theta_M2_achieved=theta_M2;
                end

            end
        end
    theta_M1_min_i=theta_M1_achieved-pace*10;
    theta_M1_max_i=theta_M1_achieved+pace*10;
    theta_M2_min_i=theta_M2_achieved-pace*10;
    theta_M2_max_i=theta_M2_achieved+pace*10;
    
    if (theta_M1_min_i<theta_M1_min)
       theta_M1_min_i=theta_M1_min;
    end
    if (theta_M1_max_i>theta_M1_max)
       theta_M1_max_i=theta_M1_max;
    end
    if (theta_M2_min_i<theta_M2_min)
       theta_M2_min_i=theta_M2_min;
    end
    if (theta_M2_min_i>theta_M2_max)
       theta_M2_min_i=theta_M2_max;
    end
    
    out_range_it=out_range_it+1;
    
    if (out_range_it>max_search_loops)
        disp('Point is out of range')
        break
    end
    
    end
    theta_M1=theta_M1_achieved;
    theta_M2=theta_M2_achieved;
    
    P1=[0,0];
    P2=[-lb*cos(theta1),lb*sin(theta1)];
    P3=[la*cos(theta_M1),la*sin(theta_M1)];

    %Intermediate calculus for P4
    XB_rot=(P2(1)-P1(1))*cos(theta_M1)+(P2(2)-P1(2))*sin(theta_M1);
    YB_rot=-(P2(1)-P1(1))*sin(theta_M1)+(P2(2)-P1(2))*cos(theta_M1);

    f=sqrt(((la-XB_rot)*(la-XB_rot))+((YB_rot)*(YB_rot)));
    beta=acos(((lb*lb)-(lc*lc)+(f*f))/(2*lb*f));
    gamma=atan2((YB_rot),(la-XB_rot));
    theta134=deg2rad(180)-gamma-beta;
    P4=P3 + ld * [cos(theta134+theta_M1),sin(theta134+theta_M1)];

    P5=[le*cos(theta_M2),le*sin(theta_M2)];

    %Intermediate calculus for P6
    XB_rot=(P5(1)-P1(1))*cos(theta_M1)+(P5(2)-P1(2))*sin(theta_M1);
    YB_rot=-(P5(1)-P1(1))*sin(theta_M1)+(P5(2)-P1(2))*cos(theta_M1);

    f=sqrt(((la-XB_rot)*(la-XB_rot))+((YB_rot)*(YB_rot)));
    beta=acos(((le*le)-(lc*lc)+(f*f))/(2*le*f));
    gamma=atan2((YB_rot),(la-XB_rot));
    theta136=deg2rad(180)-gamma-beta;
    P6=P3 + lf * [cos(theta136+theta_M1),sin(theta136+theta_M1)];

    theta34=atan2((P4(2)-P3(2)),(P3(1)-P4(1)));
    P7=P3 + lj * [cos(pi-theta34-theta37),sin(pi-theta34-theta37)];
    theta68=atan2((P3(2)-P6(2)),(P3(1)-P6(1)));
    P8=P6 + (lf+li) * [cos(theta68),sin(theta68)];

    %Intermediate calculus for P9
    XB_rot=(P7(1)-P3(1))*cos(theta68)+(P7(2)-P3(2))*sin(theta68);
    YB_rot=-(P7(1)-P3(1))*sin(theta68)+(P7(2)-P3(2))*cos(theta68);

    f=sqrt(((li-XB_rot)*(li-XB_rot))+((YB_rot)*(YB_rot)));
    beta=acos(((lj*lj)-(lc*lc)+(f*f))/(2*lj*f));
    gamma=atan2((YB_rot),(li-XB_rot));
    theta389=deg2rad(180)-gamma-beta;

    P9=P8 + lj * [cos(theta389),sin(theta389)];

    theta89=atan2((P8(1)-P9(1)),(P9(2)-P8(2)));
    P10=P8 + lk * [cos(theta810+theta89),sin(theta810+theta89)];
    
    %Plotting the current position
    plot([P1(1) P3(1)],[P1(2) P3(2)]);
    hold on;
    fill([-15 15 21 -21],[0 0 -15 -15],[0 0 -15 -15],'k');
    plot([P1(1) P2(1) P4(1) P3(1)],[P1(2) P2(2) P4(2) P3(2)]);
    plot([P1(1) P5(1) P6(1) P3(1)],[P1(2) P5(2) P6(2) P3(2)]);
    fill([P3(1) P4(1) P7(1)],[P3(2) P4(2) P7(2)],'g');
    plot([P3(1) P7(1) P9(1) P8(1) P3(1)],[P3(2) P7(2) P9(2) P8(2) P3(2)]);
    plot(P10(1),P10(2),'*','Color',[1 0 0]);
    fill([P8(1) P9(1) P10(1)],[P8(2) P9(2) P10(2)],'b');
    axis ([-60 160 -20 160]);
    axis('square');
    hold off;
    
    %Result
    disp('Angle for the forward arm')
    rad2deg(theta_M1_achieved)
    disp('Angle for the vertical arm')
    rad2deg(theta_M2_achieved)
    disp('Desired point')
    P10_desired
    disp('Achieved point')
    P10_achieved  
end


%****************************************************************************************************************************
%Visualizing image with possible positions
if image
    P10_max_height=[0,0];
    P10_min_height=[0,0];
    P10_max_lenght=[0,0];
    P10_min_lenght=[0,0];
    
    for(theta_M1 = theta_M1_min:0.01:theta_M1_max)
        for(theta_M2 = theta_M2_min:0.01:theta_M2_max)
            P1=[0,0];
            P2=[-lb*cos(theta1),lb*sin(theta1)];
            P3=[la*cos(theta_M1),la*sin(theta_M1)];

            % %Intermediate calculus for P4
            XB_rot=(P2(1)-P1(1))*cos(theta_M1)+(P2(2)-P1(2))*sin(theta_M1);
            YB_rot=-(P2(1)-P1(1))*sin(theta_M1)+(P2(2)-P1(2))*cos(theta_M1);

            f=sqrt(((la-XB_rot)*(la-XB_rot))+((YB_rot)*(YB_rot)));
            beta=acos(((lb*lb)-(lc*lc)+(f*f))/(2*lb*f));
            gamma=atan2((YB_rot),(la-XB_rot));
            theta134=deg2rad(180)-gamma-beta;
            P4=P3 + ld * [cos(theta134+theta_M1),sin(theta134+theta_M1)];

            P5=[le*cos(theta_M2),le*sin(theta_M2)];

            % %Intermediate calculus for P6
            XB_rot=(P5(1)-P1(1))*cos(theta_M1)+(P5(2)-P1(2))*sin(theta_M1);
            YB_rot=-(P5(1)-P1(1))*sin(theta_M1)+(P5(2)-P1(2))*cos(theta_M1);

            f=sqrt(((la-XB_rot)*(la-XB_rot))+((YB_rot)*(YB_rot)));
            beta=acos(((le*le)-(lc*lc)+(f*f))/(2*le*f));
            gamma=atan2((YB_rot),(la-XB_rot));
            theta136=deg2rad(180)-gamma-beta;
            P6=P3 + lf * [cos(theta136+theta_M1),sin(theta136+theta_M1)];

            theta34=atan2((P4(2)-P3(2)),(P3(1)-P4(1)));
            P7=P3 + lj * [cos(pi-theta34-theta37),sin(pi-theta34-theta37)];
            theta68=atan2((P3(2)-P6(2)),(P3(1)-P6(1)));
            P8=P6 + (lf+li) * [cos(theta68),sin(theta68)];

            % %Intermediate calculus for P9
            XB_rot=(P7(1)-P3(1))*cos(theta68)+(P7(2)-P3(2))*sin(theta68);
            YB_rot=-(P7(1)-P3(1))*sin(theta68)+(P7(2)-P3(2))*cos(theta68);

            f=sqrt(((li-XB_rot)*(li-XB_rot))+((YB_rot)*(YB_rot)));
            beta=acos(((lj*lj)-(lc*lc)+(f*f))/(2*lj*f));
            gamma=atan2((YB_rot),(li-XB_rot));
            theta389=deg2rad(180)-gamma-beta;

            P9=P8 + lj * [cos(theta389),sin(theta389)];

            theta89=atan2((P8(1)-P9(1)),(P9(2)-P8(2)));
            P10=P8 + lk * [cos(theta810+theta89),sin(theta810+theta89)];
            
            if ((P10_max_height(1)==0 && P10_max_height(2)==0)||(P10(2)>P10_max_height(2)))
                P10_max_height=P10;
            end
            
            if ((P10_min_height(1)==0 && P10_min_height(2)==0)||(P10(2)<P10_min_height(2)))
                P10_min_height=P10;
            end
            
            if ((P10_min_lenght(1)==0 && P10_min_lenght(2)==0)||(P10(1)>P10_max_lenght(1)))
                P10_max_lenght=P10;
            end
            
            if ((P10_min_lenght(1)==0 && P10_min_lenght(2)==0)||(P10(1)<P10_min_lenght(1)))
                P10_min_lenght=P10;
            end

            %Plotting the current position
            plot(P10(1),P10(2),'*','Color',[1 0 0]);
            hold on;
            
        end
    end
    
    theta_M1=theta_M1_max;
    theta_M2=theta_M2_max;
    
    P1=[0,0];
    P2=[-lb*cos(theta1),lb*sin(theta1)];
    P3=[la*cos(theta_M1),la*sin(theta_M1)];

    %Intermediate calculus for P4
    XB_rot=(P2(1)-P1(1))*cos(theta_M1)+(P2(2)-P1(2))*sin(theta_M1);
    YB_rot=-(P2(1)-P1(1))*sin(theta_M1)+(P2(2)-P1(2))*cos(theta_M1);

    f=sqrt(((la-XB_rot)*(la-XB_rot))+((YB_rot)*(YB_rot)));
    beta=acos(((lb*lb)-(lc*lc)+(f*f))/(2*lb*f));
    gamma=atan2((YB_rot),(la-XB_rot));
    theta134=deg2rad(180)-gamma-beta;
    P4=P3 + ld * [cos(theta134+theta_M1),sin(theta134+theta_M1)];

    P5=[le*cos(theta_M2),le*sin(theta_M2)];

    %Intermediate calculus for P6
    XB_rot=(P5(1)-P1(1))*cos(theta_M1)+(P5(2)-P1(2))*sin(theta_M1);
    YB_rot=-(P5(1)-P1(1))*sin(theta_M1)+(P5(2)-P1(2))*cos(theta_M1);

    f=sqrt(((la-XB_rot)*(la-XB_rot))+((YB_rot)*(YB_rot)));
    beta=acos(((le*le)-(lc*lc)+(f*f))/(2*le*f));
    gamma=atan2((YB_rot),(la-XB_rot));
    theta136=deg2rad(180)-gamma-beta;
    P6=P3 + lf * [cos(theta136+theta_M1),sin(theta136+theta_M1)];

    theta34=atan2((P4(2)-P3(2)),(P3(1)-P4(1)));
    P7=P3 + lj * [cos(pi-theta34-theta37),sin(pi-theta34-theta37)];
    theta68=atan2((P3(2)-P6(2)),(P3(1)-P6(1)));
    P8=P6 + (lf+li) * [cos(theta68),sin(theta68)];

    %Intermediate calculus for P9
    XB_rot=(P7(1)-P3(1))*cos(theta68)+(P7(2)-P3(2))*sin(theta68);
    YB_rot=-(P7(1)-P3(1))*sin(theta68)+(P7(2)-P3(2))*cos(theta68);

    f=sqrt(((li-XB_rot)*(li-XB_rot))+((YB_rot)*(YB_rot)));
    beta=acos(((lj*lj)-(lc*lc)+(f*f))/(2*lj*f));
    gamma=atan2((YB_rot),(li-XB_rot));
    theta389=deg2rad(180)-gamma-beta;

    P9=P8 + lj * [cos(theta389),sin(theta389)];

    theta89=atan2((P8(1)-P9(1)),(P9(2)-P8(2)));
    P10=P8 + lk * [cos(theta810+theta89),sin(theta810+theta89)];
    
    %Plotting the current position
    plot([P1(1) P3(1)],[P1(2) P3(2)]);
    hold on;
    fill([-15 15 21 -21],[0 0 -15 -15],'k');
    plot([P1(1) P2(1) P4(1) P3(1)],[P1(2) P2(2) P4(2) P3(2)]);
    plot([P1(1) P5(1) P6(1) P3(1)],[P1(2) P5(2) P6(2) P3(2)]);
    fill([P3(1) P4(1) P7(1)],[P3(2) P4(2) P7(2)],'g');
    plot([P3(1) P7(1) P9(1) P8(1) P3(1)],[P3(2) P7(2) P9(2) P8(2) P3(2)]);
    plot(P10(1),P10(2),'*','Color',[1 0 0]);
    fill([P8(1) P9(1) P10(1)],[P8(2) P9(2) P10(2)],'b');
    axis ([-60 160 -20 160]);
    axis('square');
    hold off;
    
    disp('The point with maximum height is: ')
    P10_max_height
    disp('The point with minimum height is: ')
    P10_min_height
    disp('The point with maximum lenght is: ')
    P10_max_lenght
    disp('The point with minimum lenght is: ')
    P10_min_lenght
    
end