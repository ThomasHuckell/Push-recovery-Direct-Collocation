function [soln,fval] = trajOpt(p,plotFlag)



% take initial guess and convert to 
Z0 = packDecVar(p.knot.state,p.knot.control);


%% Optimization setting


option=optimoptions('fmincon','Algorithm','sqp',...
    'Display','iter-detailed',...
    'MaxFunctionEvaluations',1e+6,'MaxIterations',1e+5,...
    'StepTolerance',1e-10);

A0  = [];
b   = [];
Aeq = [];
beq = [];


[lb, ub] = Bnds(p);

[Z,fval,exitflag,output]=fmincon(...
    @(Z) costFunNormState(Z,p),...
    Z0,A0,b,Aeq,beq,lb,ub,...
    @(Z) conFun(Z,p),...
    option);

[x,u] = unPackDecVar(Z,p.pack);

time = p.time;


[X,U,T] = trapInt(x,u,p,time);

soln.state   = X;
soln.control = U;
soln.time    = T;
soln.knot.state = x;
soln.knot.control = u;


if plotFlag == 1
    xSize = p.pack.xSize(1);
    uSize = p.pack.uSize(1);
    
    info  = p.pack.info;
    
    figure()
    for i = 1:xSize/2
        
        lbl = info.state([i,i+xSize/2]);
        
        
        subplot(xSize/2,1,i)
        hold all
        plot(T,X(i,:))
        plot(T,X(xSize/2 + i,:))
        yline(0,'k:');
        xline(p.push.duration,'k');
        hold off
        legend(lbl,'interpreter','latex')
    end
    
    xlabel('time [s]')
    
    figure()
    for i = 1:uSize
        
        lbl = info.control(i);
        
        subplot(uSize,1,i)
        hold all
        plot(T,U(i,:))
        xline(p.push.duration,'k');
        yline(0,'k:');
        hold off
        ylabel(lbl,'interpreter','latex')
        
    end
    
    xlabel('time [s]')
end

end