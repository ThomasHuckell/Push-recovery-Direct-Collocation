
function [soln] = SimOptTraj(push,model,collocation)


% Disturbance parameters
pushDur     =  push.time;      % duration force is applied
pushForce   =  push.force;     % magnitude of force [N]


template = model.template;

%% Model Parameters
g           = 9.81;     % gravitational accelereation [m/s/s]
z0          = model.restHeight;        % resting CoM height [m]
m           = model.mass;       % mass [Kg]
delta       = model.supportSize;      % base of support size [m]

%FW param
tauMax      = model.tau;     % maximum flywheel torque [Nm]
thetaMax    = model.theta;    % maximum flywheel angular rotation [rad]
J           = model.inertia;      % rotational inertia of the Flywheel

% VHIP param
zddot       = model.zddot;
zmax        = model.zmax;
zmin        = model.zmin;


p.parameter.mass = m;  % (kg)  mass
p.parameter.inertia = 10;   % (kg) pole mass
p.parameter.gravity = 9.81;  % (m/s^2) gravity
p.parameter.restHeight = z0;

p.push.force = pushForce;
p.push.time  = pushDur;

p.template   = template;

%% Collocation parameters

N = collocation.points;     % Number of knot points
n = 3;       % numeber on knot point during push

t0 = 0;
simTime = 1.5;

pushGrid = linspace(t0,pushDur,n);
recoveryGrid = linspace(pushDur+0.05,simTime,N-n);


switch template 
    case "LIP"
%% LIP 

x0 = [0;0];    
xf = [0;0];

xmax = [1;10];
xmin = [-1;-10];

umax = delta;
umin = -delta;

% Guess solution
X = zeros(2,N);
U = zeros(1,N);

p.dynamics   = @(x,u,p,f) LIP(x,u,p,f);
p.pack.info.state = ["$x [m]$"; "$\dot{x} [\frac{m}{s}]$"];
p.pack.info.control = "$x_c [m]$";
    case "LIPPFW"
%% FW
x0 = [0;0;0;0];    
xf = [0;0;0;0];

xmax = [1;thetaMax;10;10];
xmin = [-1;-pi/6;-10;-10];

umax = [delta;tauMax];
umin = [-delta;-tauMax];

% Guess solution
X = zeros(4,N);
U = zeros(2,N);

p.dynamics   = @(x,u,p,f) FW(x,u,p,f);
p.pack.info.state = ["$x [m]$"; "$\theta [rad]$"; "$\dot{x} [\frac{m}{s}]$"; "$\dot{\theta} [\frac{rad}{s}]$"];
p.pack.info.control = ["$x_c$ [m]"; "$\tau$ [Nm]"];
    case "VHIP"
%% VHIP
x0 = [0;1;0;0];    
xf = [0;1;0;0];

xmax = [1; zmax; 10; 10];
xmin = [-1; zmin; -10; -10];

umax = [delta; zddot];
umin = [-delta; -zddot];

% Guess solution
X = zeros(4,N);
U = zeros(2,N);

p.pack.info.state = ["$x [m]$"; "$z [m]$"; "$\dot{x} [\frac{m}{s}]$"; "$\dot{z} [\frac{m}{s}]$"];
p.pack.info.control = ["$x_c$ [m]"; "$\ddot{z} [\frac{m}{s^2}]$"];

p.dynamics = @(x,u,p,f) VHIP(x,u,p,f);

    case "VHIPPFW"
%% VHIP + FW
x0 = [0;0;1;0;0;0];    
xf = [0;0;1;0;0;0];

xmax = [1; thetaMax; zmax;10;10;10];
xmin = [-1; -pi/6; zmin; -10;-10;-10];

umax = [delta; tauMax; zddot];
umin = [-delta; -tauMax; -zddot];

p.pack.info.state = ["$x [m]$"; "$\theta [rad]$"; "$z$"; "$\dot{x} [\frac{m}{s}]$"; "$\dot{\theta} [\frac{rad}{s}]$"; "$\dot{z} [\frac{m}{s}]$"];
p.pack.info.control = ["$x_c [m]$"; "$\tau$ [Nm]"; "$\ddot{z}[\frac{m}{s^2}]$"];

% Guess solution
X = zeros(6,N);
U = zeros(3,N);

p.dynamics = @(x,u,p,f) VHIPPFW(x,u,p,f);

end
%%

p.pack.xSize = size(X);
p.pack.uSize = size(U);

p.knot.points     = N;
p.knot.pushPoints = n;

p.time = [pushGrid,recoveryGrid];

p.knot.points  = N;
p.knot.time    = [pushGrid,recoveryGrid];
p.knot.state   = X;
p.knot.control = U;

p.bounds.state  = [xmin xmax];
p.bounds.control = [umin umax];

p.boundry.initial = x0;
p.boundry.final   = xf;


soln = trajOpt(p);

end
