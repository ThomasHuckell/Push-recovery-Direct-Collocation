%% VHIP + FW Direct collocation comparison
% this script is used to simulate a large range of push recovery
% simulations using trajectory optimization. Set push time and range of
% push forces magnitudes.

% Thomas Huckell
% January 22 2021
clear
clc
close all

addpath("models", "trajectory optimization","animation","guess","plotting")


simFlag = 1;


if simFlag == 1

pushDuration = 0.1;

pushForce1 = [20:20:520,525];
pushForce2 = [20:20:600,605,609];
pushForce3 = [20:20:520,535,540,540,542,544];
pushForce4 = [20:20:620,625,627];

pushDur1   = pushDuration*ones(1,length(pushForce1));
pushDur2   = pushDuration*ones(1,length(pushForce2));
pushDur3   = pushDuration*ones(1,length(pushForce3));
pushDur4   = pushDuration*ones(1,length(pushForce4));

pushArray1 = [pushForce1; pushDur1];
pushArray2 = [pushForce2; pushDur2];
pushArray3 = [pushForce3; pushDur3];
pushArray4 = [pushForce4; pushDur4];

knotPts = [50;3];
simTime = 5;


result_LIP     = pushOptComp("LIP",pushArray1,knotPts,simTime);
result_LIPPFW  = pushOptComp("LIPPFW",pushArray2,knotPts,simTime);
result_VHIP    = pushOptComp("VHIP",pushArray3,knotPts,simTime);
[result_VHIPPFW , param] = pushOptComp("VHIPPFW",pushArray4,knotPts,simTime);


fileLabel = strcat("pushData","_",string(pushDuration),datestr(now,'mm-dd-yyyy HH-MM'),".mat");
trajOptRecovery   = struct('parameters',param,'simData',struct('LIP',result_LIP,'LIPPFW',result_LIPPFW,'VHIP',result_VHIP,'VHIPPFW',result_VHIPPFW));

save(fileLabel,'trajOptRecovery')

end

%% Plotting

plotRelativeControl(result_VHIPPFW,"VHIPPFW")
plotRelativeControl(result_VHIP,"VHIP")
plotRelativeControl(result_LIPPFW,"LIPPFW")


plotSolveTime([result_LIP.solverTime], [result_LIPPFW.solverTime], [result_VHIP.solverTime], [result_VHIPPFW.solverTime], result_LIP(1).sim.time(end))

plotExcursion(result_LIP,result_LIPPFW,result_VHIP,result_VHIPPFW)

plotWork(result_LIP,result_LIPPFW,result_VHIP,result_VHIPPFW)

%% Functions

function [result,param] = pushOptComp(model,pushArray,knotPts,simTime)


addpath("models", "trajectory optimization")

g = 9.81;
push = pushArray(:,1);
p = modelInit(model,push,simTime,knotPts);

param = p.parameter;

hbarSim = waitbar(0,strcat(p.template,': simulation progress'));

N = size(pushArray,2);

for i = 1:N
    
    waitbar(i/N,hbarSim)
    
    
    if(i == 1)
        % do nothing
    else
        
        % update push force;
        push = pushArray(:,i);
        p.push.force = push(1);
        
        % update inital guess
        p.knot.state = X.knot.state;
        p.knot.control = X.knot.control;
        
    end

    tic
    X = trajOpt(p,0);
    optTime = toc;
    
    result(i).pushParam         = push;
    result(i).sim.state         = X.state;
    result(i).sim.control       = X.control;
    result(i).sim.time          = X.time;
    result(i).controlCompContribution    = controlContribution(X.control,p);
    result(i).solverTime        = optTime;
    
    flywheelPower = zeros(1,length(X.time));
    vertPower = zeros(1,length(X.time));

    switch model
        case "LIP"
            result(i).excursion  = [max(X.state(1,:));
                                    max(X.state(2,:));
                                    max(X.state(1,:) + X.state(2,:)/sqrt(g/p.parameter.restHeight))];
            
            
            
            
            phi_dot = -X.state(2,:)./(1+ X.state(1,:).^2); % ankle angle: d/dt(arctan(z(t)/x(t))
            
            anklePower = X.control(1,:)*p.parameter.mass*g.*phi_dot; % ankle Power: x_cop*f_gr*phi_dot
            
            
        case "LIPPFW"
            result(i).excursion   = [max(X.state(1,:));
                                     max(X.state(3,:));
                                     max(X.state(1,:) + X.state(3,:)/sqrt(g/p.parameter.restHeight))];
                                 
            phi_dot = -X.state(3,:)./(1+ X.state(1,:).^2); % ankle angle: d/dt(arctan(z(t)/x(t))
            
            anklePower = X.control(1,:)*p.parameter.mass*g.*phi_dot; % ankle Power: x_cop*f_gr*phi_dot
            
            
            flywheelPower = X.control(2,:).*X.state(4,:);   
            
            
            
        case "VHIP"
            result(i).excursion   = [max(X.state(1,:));
                                     max(X.state(3,:));
                                     max(X.state(1,:) + X.state(3,:).*sqrt(X.state(2,:)/g))];
            
            phi_dot = (X.state(4,:).*X.state(1,:)-X.state(3,:).*X.state(2,:))./(X.state(2,:).^2+ X.state(1,:).^2); % ankle angle: d/dt(arctan(z(t)/x(t))
            
            anklePower = X.control(1,:)*p.parameter.mass.*(g+X.control(2,:)).*phi_dot; % ankle Power: x_cop*f_gr*phi_dot                     
                                 
            vertPower = p.parameter.mass*(g+X.control(2,:)).*X.state(4,:);
            
            
            
        case "VHIPPFW"
            result(i).excursion   = [max(X.state(1,:));
                                     max(X.state(4,:));
                                     max(X.state(1,:) + X.state(4,:).*sqrt(X.state(3,:)/g))];
                                 
            phi_dot = (X.state(6,:).*X.state(1,:)-X.state(4,:).*X.state(3,:))./(X.state(3,:).^2+ X.state(1,:).^2); % ankle angle: d/dt(arctan(z(t)/x(t))
            
            anklePower = X.control(1,:)*p.parameter.mass.*(g+X.control(3,:)).*phi_dot; % ankle Power: x_cop*f_gr*phi_dot
            
            flywheelPower = X.control(2,:).*X.state(5,:);   
            
            vertPower = p.parameter.mass*(g+X.control(3,:)).*X.state(6,:);
    end
    
    % Looking at the positive power
    anklePower( anklePower <=0) = 0;
    flywheelPower( flywheelPower <=0 ) = 0;
    vertPower( vertPower <= 0) = 0;
    
    
    ankleWork = cumtrapz(X.time,anklePower);
    flywheelWork = cumtrapz(X.time,flywheelPower);
    vertWork = cumtrapz(X.time,vertPower);
    
    result(i).work = [ankleWork(end),flywheelWork(end),vertWork(end)];
end

close(hbarSim)

end

function uPercent = controlContribution(u,p)

uNormalized = zeros(size(u));       % initilize Normalized control = u_i/u_i{max}
compCost    = zeros(size(u,1),1);   % Normalized cost of control for each component

    for i = 1:p.pack.uSize(1)
        uNormalized(i,:) = u(i,:)/p.bounds.control(i,2);
        compCost(i) = uNormalized(i,:) * uNormalized(i,:)';
    end

totalCost = sum(compCost);    

uPercent = compCost/totalCost;
    
end





