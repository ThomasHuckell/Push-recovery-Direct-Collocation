function [] = plotRelativeControl(result,model,fileRoot)

percentControl = zeros(size(result(1).controlCompContribution,1),length(result));
pushParam      = zeros(2,length(result));


spec = plotSpec();


switch model
    case "LIP"
        plotspc = spec.ankle;
        leg = '$x_c$';
        
    case "LIPPFW"
        plotspc = [spec.ankle;
                   spec.hip];
        leg = [{'$x_c$'},{'$\tau$'}];
        
    case "VHIP"
        plotspc = [spec.ankle;
                   spec.toe];
        leg = [{'$x_c$'},{'$\ddot{z}$'}];
        
    case "VHIPPFW"
        plotspc = [spec.ankle;
                   spec.hip;
                   spec.toe];
        
        leg = [{'$x_c$'},{'$\tau$'},{'$\ddot{z}$'}];
end

    for i = 1:length(result)

        percentControl(:,i) = result(i).controlCompContribution;
        pushParam(:,i) = result(i).pushParam;   

    end

    f1 = figure('Position',[100 100 750 300]);
    hold all
    for i = 1:size(percentControl,1)
        plot(pushParam(1,:),percentControl(i,:),plotspc{i,:})
    end
        
    xlabel('Push Force [N]',spec.ltxFMT{:})
    ylabel('Control Contribution \%',spec.ltxFMT{:})
    legend(leg,'Location','east',spec.ltxFMT{:})
    xlim([100,700])
    exportgraphics(f1,strcat(fileRoot,model,'_relativeControl.png'),'resolution',300)
end