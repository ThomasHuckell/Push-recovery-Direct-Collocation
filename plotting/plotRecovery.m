function plotRecovery(data,model,aux)

if nargin < 3
    
    desiredPush     = 0;
    timeFrames      = [0,0.2,0.3,0.4,0.5,0.6,0.9,1,1.1,1.2,1.5];
    flags           = struct('save',1,'animate',1);
    timeRange       = [0,inf];
    
    aux             = struct('desiredPush',desiredPush,'timeFrames',timeFrames,'plotFlags',flags,'timeRange',timeRange);
else
    
    if ~isfield(aux,'desiredPush')
        aux.desiredPush = 0;
    end
    
    if ~isfield(aux,'timeFrames')
        aux.timeFrames  = [0,0.2,0.3,0.4,0.5,0.6,0.9,1,1.1,1.2,1.5];
    end
    
    if ~isfield(aux,'flags')
        aux.flags   = struct('state',1,'control',1,'animate',1,'timeLapse',1);
    end
    
    if ~isfield(aux,'timeRange')
        aux.timeRange = [0,inf];
    end
    
    
end

if aux.desiredPush == 0
   pushIndex = size(data.simData.(model),2);
else
    pushIndex = 1;
    prevErr = inf;
    for i = 1:size(data.simData.(model),2)
        
        pushErr = abs(data.simData.(model)(1,i).pushParam(1)-aux.desiredPush);
        
        if pushErr == 0
            pushIndex = i;
            break
            
        elseif pushErr < prevErr
            pushIndex = i;
            
        else
            break
        end
        
        
    end
    
    
end


modelData = data.simData.(model)(1,pushIndex);
param     = data.parameters;

spec = plotSpec();

stateLBL        = stateLabel(model);
controlLBL      = controlLabel(model);

pushForce = modelData.pushParam(1);
pushDur   = modelData.pushParam(2);
pushOnset = 0;



t_start = aux.timeRange(1);
t_end   = min(aux.timeRange(2),modelData.sim.time(end));

[~,ind_start] = min(abs(modelData.sim.time-t_start));
[~,ind_end]   = min(abs(modelData.sim.time-(t_start+t_end)));

state   = modelData.sim.state(:,ind_start:ind_end)';

switch model
    case 'VHIP'
        state(:,2) = state(:,2)-param.restHeight;
    case 'VHIPPFW'
        state(:,3) = state(:,3)-param.restHeight;
end

control = modelData.sim.control(:,ind_start:ind_end)';

time    = modelData.sim.time(ind_start:ind_end)';

N = size(state,2);

% state evloution model
f1 = figure('Position',[100 100 750 N/2*150]);
for i = 1:N/2
    subplot(N/2,1,i)
    hold all
    plot(time,state(:,i),spec.state{1,:})
    plot(time,state(:,i+N/2),spec.state{2,:})
    if i == 1
        pushRegion(pushOnset,pushDur,1);
    else
        pushRegion(pushOnset,pushDur,0);
    end
    plotRef(0)
    hold off
    legend(stateLBL{[i,i+N/2]},spec.ltxFMT{:})
    xlim([t_start, t_end])
    
    if isfield(aux,'axis')
        if (model == "VHIP" && i== 2)
            ylim(aux.axis.state(3,:));
        else
            ylim(aux.axis.state(i,:));
        end
    end
end
xlabel('time [s]',spec.ltxFMT{:});


% control evolution model
f2 = figure('Position',[100 100 750 N/2*150]);
for i = 1:N/2
    subplot(N/2,1,i)
    hold all
    plot(time,control(:,i),spec.control{1,:})
    ylabel(controlLBL{:,i},spec.ltxFMT{:});
    if i == 1
        pushRegion(pushOnset,pushDur,1);
    else
        pushRegion(pushOnset,pushDur,0);
    end
    plotRef(0)
    xlim([t_start, t_end])
    
    if isfield(aux,'axis')
        if (model == "VHIP" && i== 2)
            ylim(aux.axis.control(3,:));
        else
            ylim(aux.axis.control(i,:));
        end
    end
    
    hold off
end
xlabel('time [s]',spec.ltxFMT{:});



if aux.flags.save == 1
    fileNameRoot = strcat('figures\',model,'\trajOptRecovery_',model,'_',num2str(pushForce),'N_1e-1s_');
    exportgraphics(f1,strcat(fileNameRoot,'StateTrj','.png'),'Resolution',300)
    exportgraphics(f2,strcat(fileNameRoot,'ControlTrj','.png'),'Resolution',300)
end

IP_animator(modelData,param,model,fileNameRoot,aux)
    




end

function pushRegion(onSet,dur,labelFlag)
    
    gcf;
    
    y1 = ylim();
    
    x = [onSet,onSet,onSet+dur,onSet+dur];
    y = [y1(1)-100,y1(2)+100,y1(2)+100,y1(1)-100];
    
    v = [x',y'];
    f = [1 2 3 4];
    
    patch('Faces',f,'Vertices',v,'FaceColor','#D3D3D3','FaceAlpha',0.5')
    
    ylim(y1+[-.2*y1(2) .3*y1(2)]);
    
    if labelFlag == 1
        spec = plotSpec();
        text(onSet+dur,1.15*y1(2),'$\leftarrow$ Push Region',spec.ltxFMT{1:2});
    end

end

function plotRef(yRef)
    gcf;
    
    
    x = xlim();
    
    plot(x,[yRef,yRef],'--','Color','#B1B1B1','HandleVisibility','off')

end


