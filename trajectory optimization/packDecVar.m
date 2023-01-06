function [z, pack] = packDecVar(x,u)
    % packDecVar pack the collocation vectors x and u into one vector to
    % use for fmincon.
    
    z = zeros(numel(x)+numel(u),1);
    
    pack.xSize = size(x);
    pack.uSize = size(u);
    
    for i = 1:pack.xSize(1)
        z((i-1)*pack.xSize(2)+1:(i)*pack.xSize(2)) = x(i,:);
    end
    
    for c = 1:pack.uSize(1)
        z((i+c-1)*pack.xSize(2)+1:(i+c)*pack.xSize(2)) = u(c,:);
    end
    
end