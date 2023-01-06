function [x,u] = unPackDecVar(z,pack)
    % unPackDecVar unpacks the z vector from fmincon and returns the states
    % and controls
    
    x = zeros(pack.xSize);
    u = zeros(pack.uSize);
    
    
    for i = 1:pack.xSize(2)
        for j = 1:pack.xSize(1)
            x(j,i) = z((j-1)*pack.xSize(2)+i);
        end
        for c = 1:pack.uSize(1)
            u(c,i) = z((pack.xSize(1)+c-1)*pack.xSize(2)+i);
        end
        
    end
    
end