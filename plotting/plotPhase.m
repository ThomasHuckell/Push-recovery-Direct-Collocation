function plotPhase(data,desiredPush)

spec = plotSpec();
f1 = figure('Position',[100 100 750 300]);
hold on

for model = ["LIP","LIPPFW","VHIP","VHIPPFW"]
    
    ind = 1;
    prevErr = inf;
    
    for i=1:size(data.(model),2)
        
        err = abs(data.(model)(1,i).pushParam(1)-desiredPush);
        
        if err == 0
            ind = i;
            break
        elseif err < prevErr
            ind = i;
        else
            break
        end
    end    
        
        switch model
            
            case "LIP"
                
                plot(data.(model)(1,ind).sim.state(1,:),data.(model)(1,ind).sim.state(2,:),spec.LIP{:})
                
            case "LIPPFW"
                
                plot(data.(model)(1,ind).sim.state(1,:),data.(model)(1,ind).sim.state(3,:),spec.LIPPFW{:})
                
            case "VHIP"
                
                plot(data.(model)(1,ind).sim.state(1,:),data.(model)(1,ind).sim.state(3,:),spec.VHIP{:})
                
                
            case "VHIPPFW"
                
                plot(data.(model)(1,ind).sim.state(1,:),data.(model)(1,ind).sim.state(4,:),spec.VHIPPFW{:})
                
        end
        
        
    
end

legend("LIP","LIPPFW","VHIP","VHIPPFW",spec.ltxFMT{:});
xlabel('$x$ [m]',spec.ltxFMT{:})
ylabel('$\dot{x}$ [m/s]',spec.ltxFMT{:})

exportgraphics(f1,strcat('figures\comparison\phaseComp_',num2str(desiredPush),'N_1e-1s.png'),'Resolution',300)
end