function Dy = LIP(y,u,p,f)

% Set model Parameters
g   = p.parameter.gravity;
z0  = p.parameter.restHeight;
m   = p.parameter.mass;


xCop = u;

% Determine Desired CoP location;

Dy = zeros(2,1);

Dy(1) = y(2);
Dy(2) = g/z0*(y(1) - xCop) + f/m;


end

