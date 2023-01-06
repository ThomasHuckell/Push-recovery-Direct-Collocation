function Dq = VHIPPFW(q,u,p,f)


g   = p.parameter.gravity;
m   = p.parameter.mass;
J   = p.parameter.inertia;

%%

x_dot        = q(4);
theta_dot    = q(5);
z_dot        = q(6);

delta        = u(1);
tau          = u(2);
z_ddot       = u(3);


x_ddot       = (z_ddot + g)/q(3)*(q(1) - delta) -tau/(m*q(3)) + f/m;
theta_ddot   = tau/J;

Dq = [x_dot; theta_dot; z_dot; x_ddot; theta_ddot; z_ddot];
end