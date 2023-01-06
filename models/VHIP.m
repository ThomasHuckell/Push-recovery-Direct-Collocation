function Dq = VHIP(q,u,p,f)


g   = p.parameter.gravity;
m   = p.parameter.mass;


%%

x_dot        = q(3);
z_dot        = q(4);

delta        = u(1);
z_ddot       = u(2);

x_ddot       = (z_ddot + g)/q(2)*(q(1) - delta) + f/m;

Dq = [x_dot;z_dot;x_ddot;z_ddot];
end