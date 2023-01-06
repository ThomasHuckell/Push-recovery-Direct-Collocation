function [xGuess,uGuess] = initialGuess(p)

N = length(p.time);

dimX = size(p.bounds.state,1);
dimU = size(p.bounds.control,1);


uGuess = zeros(dimU,N);
    switch p.template
        
        case "VHIP"
            
            xGuess = zeros(dimX,N);
            xGuess(2,:) = p.parameter.restHeight*ones(1,N);

        case "VHIPPFW"
            xGuess = zeros(dimX,N);
            xGuess(3,:) = p.parameter.restHeight*ones(1,N);

        otherwise
            
            xGuess = zeros(dimX,N);

    end

end


