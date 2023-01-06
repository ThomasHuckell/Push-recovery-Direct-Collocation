function label = stateLabel(model)


    switch model

        case {'LIP',1}

            label = [{'$x$ [m]'},{'$\dot{x}$ [m/s]'}];

        case {'LIPPFW',2}

            label = [{'$x$ [m]'},{'$\theta$ [rad]'},{'$\dot{x}$ [m]'},{'$\dot{\theta}$ [rad/s]'}];

        case {'VHIP',3}

            label = [{'$x$ [m]'},{'$z-z_0$ [m]'},{'$\dot{x}$ [m]'},{'$\dot{z}$ [m/s]'}];

        case {'VHIPPFW',4}

           label = [{'$x$ [m]'},{'$\theta$ [rad]'},{'$z-z_0$ [m]'},{'$\dot{x}$ [m]'},{'$\dot{\theta}$ [rad/s]'},{'$\dot{z}$ [m/s]'}];
           
    end

end