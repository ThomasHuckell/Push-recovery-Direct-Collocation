function [ c, ceq ] = conFun(Z,p)
% conFun generates the constraint equations for fmin con. Here we take the
% decision variable Z, unpack it to be broken into the state and control
% collocation variables. We then construct the collocation constraints.


% unpack the state and control variables from the vector Z
[x,u] = unPackDecVar(Z,p.pack);


% extract the necessary parameters from p

xSize = p.pack.xSize(1);

N = p.knot.points;
n = p.knot.pushPoints;

Dyn = p.dynamics;
F = p.push.force;



% generate collocation constraints

ceqDyn = zeros(xSize*(N-1),1);      % initialize vector to hold collocation equality constraints

% we first loop over the collocation points were the push is applied 
for i = 1:1:n-1
    
    dt = p.time(i+1) - p.time(i);
    
    x_i = x(:,i);
    x_n = x(:,i+1);
    
    u_i = u(:,i);
    u_n = u(:,i+1);
    
    Dx_i = Dyn(x_i,u_i,p,F);   
    Dx_n = Dyn(x_n,u_n,p,F);
    
    x_dyn = x_i + 1/2*dt*(Dx_i+Dx_n);
    
    ceqDyn((i-1)*xSize+1:i*xSize) = x_dyn - x_n;
end

% iterate over remaining collocation points when the force is no longer
% applied
for i = n:1:N-1
    dt = p.time(i+1) - p.time(i);
    
    x_i = x(:,i);
    x_n = x(:,i+1);
    
    u_i = u(:,i);
    u_n = u(:,i+1);
    
    Dx_i = Dyn(x_i,u_i,p,0);
    Dx_n = Dyn(x_n,u_n,p,0);
    
    x_dyn = x_i + 1/2*dt*(Dx_i+Dx_n);
    
    ceqDyn((i-1)*xSize+1:i*xSize) = x_dyn-x_n;
end


% set boundry contraints
ceqBnds = p.boundry.initial - x(:,1);

% set collocation and boundry constraints
ceq = [ceqDyn ; ceqBnds];

c = [];

end