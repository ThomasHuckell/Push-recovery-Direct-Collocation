function [J] = costFunNormState(Z,p)
% costFunNormState generates the cost function used within fmincon
[x,u] = unPackDecVar(Z,p.pack);

uSize = p.pack.uSize(1);

weights = p.costFucntionWeights;
N = size(x,2);

J = 0;

z0 = p.parameter.restHeight;
delta = p.parameter.supportSize(2);
thetaMax = p.parameter.thetaMax;
zMax = (p.parameter.zMax-z0);

timeGrid = p.time;


uNorm = zeros(uSize,N);
for i = 1:uSize
    uNorm(i,:) = 1/p.bounds.control(i,2)*u(i,:);
end

switch p.template
    
    case "LIP"
        for i = 1:N-1
            J = J + 1/2*(timeGrid(i+1)-timeGrid(i))*( x(:,i).'*diag(weights([1,4]))*x(:,i)+ uNorm(:,i).'*uNorm(:,i) + ...
                (uNorm(:,i+1)-uNorm(:,i)).'*2.5*eye(length(uNorm(:,i)))*(uNorm(:,i+1)-uNorm(:,i)) ); 
                     
        end
    case "LIPPFW"
        
        for i = 1:N-1
            J = J + 1/2*(timeGrid(i+1)-timeGrid(i))*( x(:,i).'*diag(weights([1,2,4,5]))*x(:,i) + uNorm(:,i).'*uNorm(:,i) + ...
                (uNorm(:,i+1)-uNorm(:,i)).'*2.5*eye(length(uNorm(:,i)))*(uNorm(:,i+1)-uNorm(:,i)) );
        end
    case "VHIP"
        for i = 1:N-1
            J = J + 1/2*(timeGrid(i+1)-timeGrid(i))*( (x(:,i)-[0;z0;0;0]).'*diag(weights([1,3,4,3]))*(x(:,i)-[0;z0;0;0]) + uNorm(:,i).'*uNorm(:,i) + ...
                (uNorm(:,i+1)-uNorm(:,i)).'*2.5*eye(length(uNorm(:,i)))*(uNorm(:,i+1)-uNorm(:,i)) );
        end
    case "VHIPPFW"
        for i = 1:N-1
            J = J + 1/2*(timeGrid(i+1)-timeGrid(i))*( (x(:,i)-[0;0;z0;0;0;0]).'*diag(weights)*(x(:,i)-[0;0;z0;0;0;0])+ uNorm(:,i).'*uNorm(:,i)  + ...
                (uNorm(:,i+1)-uNorm(:,i)).'*2.5*eye(length(uNorm(:,i)))*(uNorm(:,i+1)-uNorm(:,i)) );
        end
end
