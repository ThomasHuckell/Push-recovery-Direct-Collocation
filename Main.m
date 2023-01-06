%% VHIP + FW Direct collocation

% Thomas Huckell
% January 22 2021
clear
clc
close all

addpath("models", "trajectory optimization","animation","guess")

%%

% Disturbance parameters
pushDur     = 0.1;     % duration force is applied
pushForce   = 609;      % magnitude of force [N]

pushParam = [pushForce; pushDur];

simTime = 5;

knotPoints = [50;3];

%model = "LIP";
model = "LIPPFW";
%model = "VHIP";
%model = "VHIPPFW";

if exist('p') == 1 && p.template == model
    p.knot.state   = X.knot.state;
    p.knot.control = X.knot.control;
    p.push.force   = pushForce;
else
    p = modelInit(model,pushParam,simTime,knotPoints);
end


plotFlag = 1;%%

 tic
 [X , fval] = trajOpt(p,plotFlag);
 t = toc


