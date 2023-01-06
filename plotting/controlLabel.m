function label = controlLabel(model)


    switch model

        case {'LIP',1}

            label = {'$x_c [m]$'};

        case {'LIPPFW',2}

            label = [{'$x_c [m]$'},{'$\tau [Nm]$'}];

        case {'VHIP',3}

            label = [{'$x_c [m]$'},{'$\ddot{z} [m/s^2]$'}];

        case {'VHIPPFW',4}

           label = [{'$x_c [m]$'},{'$\tau [Nm]$'},{'$\ddot{z} [m/s^2]$'}];
           
    end

end