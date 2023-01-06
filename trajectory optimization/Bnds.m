function [lb, ub] = Bnds(p)
    % Bnds creats the upper and lower bounds for the collocation variables
    % used in fmincon.

    
    xLB = p.bounds.state(:,1).*ones(size(p.knot.state));
    xUB = p.bounds.state(:,2).*ones(size(p.knot.state));
    

    uLB = p.bounds.control(:,1).*ones(size(p.knot.control));
    uUB = p.bounds.control(:,2).*ones(size(p.knot.control));
    
    % pack upper and lower bounds
    lb = packDecVar(xLB,uLB);
    ub = packDecVar(xUB,uUB);
    
    
end
