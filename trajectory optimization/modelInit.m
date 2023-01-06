function p = modelInit(model,pushParam,simTime,knotPts)


%% Model Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
z0          = 0.95;   % resting CoM height [m]
m           = 70;       % mass [Kg]
delta       = [-0.1 0.2];      % base of support size [m]

%FW param
tauMax      = 100;     % maximum flywheel torque [Nm]
thetaMax    = 0.5;    % maximum flywheel angular rotation [rad]
J           = 8;      % rotational inertia of the Flywheel

% VHIP param
zddot       = 3;
zMax        = 1;
zMin        = 0.9;

% Store infomation in structure
p.parameter.mass        = m;  % (kg)  mass
p.parameter.inertia     = J;   % (kg) pole mass
p.parameter.gravity     = 9.81;  % (m/s^2) gravity
p.parameter.restHeight  = z0;
p.parameter.supportSize = delta;
p.parameter.tauMax      = tauMax;
p.parameter.thetaMax    = thetaMax;
p.parameter.zddot       = zddot;
p.parameter.zMax        = zMax;

p.push.force            = pushParam(1);
p.push.duration         = pushParam(2);

p.template = model;

p.costFucntionWeights = [delta(2)^-2 thetaMax^-2 zMax^-2 0.4942^-2 2.5^-2 0.387^-2];
%% Collocation parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N = knotPts(1);       % Number of knot points
n = knotPts(2);       % numeber on knot point during push

t0 = 0;

pushGrid = linspace(t0,pushParam(2),n);
denseGrid = linspace(pushParam(2)+(pushGrid(2)-pushGrid(1)),2/3*simTime,ceil(.75*N));
recoveryGrid = linspace(2/3*simTime+(denseGrid(2)-denseGrid(1)),simTime,N-(n+ceil(.75*N)) +1);

timeGrid = [pushGrid,denseGrid,recoveryGrid(2:end)];

%%
switch model 
    case "LIP"
%% LIP 

x0 = [0;0];    
xf = [0;0];

xmax = [1;10];
xmin = [-1;-10];

umax = delta(2);
umin = delta(1);


p.dynamics   = @(x,u,p,f) LIP(x,u,p,f);
p.pack.info.state = ["$x [m]$"; "$\dot{x} [\frac{m}{s}]$"];
p.pack.info.control = "$x_c [m]$";
    case "LIPPFW"
%% FW
x0 = [0;0;0;0];    
xf = [0;0;0;0];

xmax = [1;thetaMax;10;10];
xmin = [-1;-thetaMax;-10;-10];

umax = [delta(2);tauMax];
umin = [delta(1);-tauMax];


p.dynamics   = @(x,u,p,f) LIPPFW(x,u,p,f);
p.pack.info.state = ["$x [m]$"; "$\theta [rad]$"; "$\dot{x} [\frac{m}{s}]$"; "$\dot{\theta} [\frac{rad}{s}]$"];
p.pack.info.control = ["$x_c$ [m]"; "$\tau$ [Nm]"];
    case "VHIP"
%% VHIP
x0 = [0;z0;0;0];    
xf = [0;z0;0;0];

xmax = [1; zMax; 10; 10];
xmin = [-1; zMin; -10; -10];

umax = [delta(2); zddot];
umin = [delta(1); -zddot];


p.pack.info.state = ["$x [m]$"; "$z [m]$"; "$\dot{x} [\frac{m}{s}]$"; "$\dot{z} [\frac{m}{s}]$"];
p.pack.info.control = ["$x_c$ [m]"; "$\ddot{z} [\frac{m}{s^2}]$"];

p.dynamics = @(x,u,p,f) VHIP(x,u,p,f);

    case "VHIPPFW"
%% VHIP + FW
x0 = [0;0;z0;0;0;0];    
xf = [0;0;z0;0;0;0];

xmax = [1; thetaMax; zMax;10;10;10];
xmin = [-1; -thetaMax; zMin; -10;-10;-10];

umax = [delta(2); tauMax; zddot];
umin = [delta(1); -tauMax; -zddot];

p.pack.info.state = ["$x [m]$"; "$\theta [rad]$"; "$z$"; "$\dot{x} [\frac{m}{s}]$"; "$\dot{\theta} [\frac{rad}{s}]$"; "$\dot{z} [\frac{m}{s}]$"];
p.pack.info.control = ["$x_c [m]$"; "$\tau$ [Nm]"; "$\ddot{z}[\frac{m}{s^2}]$"];


p.dynamics = @(x,u,p,f) VHIPPFW(x,u,p,f);

end



p.knot.points     = N;
p.knot.pushPoints = n;

p.time = timeGrid;

p.bounds.state  = [xmin xmax];
p.bounds.control = [umin umax];

p.boundry.initial = x0;
p.boundry.final   = xf;

[X, U] = initialGuess(p);
p.knot.state   = X;
p.knot.control = U;

p.pack.xSize = size(X);
p.pack.uSize = size(U);


end