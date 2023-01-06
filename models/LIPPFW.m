function Dz = LIPPFW(z,u,p,f)


g   = p.parameter.gravity;
z0  = p.parameter.restHeight;
m   = p.parameter.mass;
J   = p.parameter.inertia;

%%


x_dot        = z(3);
theta_dot    = z(4);

delta        = u(1);
tau          = u(2);


x_ddot       = g/z0*(z(1) - delta) - tau/(m*z0) + f/m ;
theta_ddot   = tau/J;



Dz = [x_dot;theta_dot;x_ddot;theta_ddot];
end