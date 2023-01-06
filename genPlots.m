addpath('Data','plotting')


data = load('pushData_0.103-23-2022 13-52.mat');

timeFrames1      = [0,0.1,0.2,0.3,0.4,0.6,0.8,1,1.2,1.5,2];
timeFrames2      = [0,0.1,0.2,0.3,0.4,0.6,0.8,1,1.2,1.5,2,2.5,3,4,5];

flags           = struct('save',1,'animate',0);
axis            = struct('control',[-0.02,0.25;-120,120;-4,4],'state',[-0.3 0.8;-1.25,2.5;-0.25,0.5]);

aux1 = struct('desiredPush',300,'timeFrames',timeFrames1,'flags',flags,'timeRange',[0,2],'axis',axis);
aux2 = struct('desiredPush',0,'timeFrames',timeFrames2,'flags',flags,'timeRange',[0,inf],'axis',axis);


LIP         = data.trajOptRecovery.simData.LIP;
LIPPFW      = data.trajOptRecovery.simData.LIPPFW;
VHIP        = data.trajOptRecovery.simData.VHIP;
VHIPPFW     = data.trajOptRecovery.simData.VHIPPFW;

exLIP       = [LIP.excursion]';
exLIPPFW    = [LIPPFW.excursion]';
exVHIP      = [VHIP.excursion]';
exVHIPPFW   = [VHIPPFW.excursion]';

hip = ((exLIP(1:26,3)+exVHIP(1:26,3))/2 - (exLIPPFW(1:26,3)+exVHIPPFW(1:26,3))/2)./((exLIP(1:26,3)+exVHIP(1:26,3))/2);



toe1 = (exLIP(1:26,3) - exVHIP(1:26,3))./exLIP(1:26,3);
toe2 = (exLIPPFW(1:30,3) - exVHIPPFW(1:30,3))./exLIPPFW(1:30,3);

mean(hip(12:end,1));


%% Individual model 
% 300N push
plotRecovery(data.trajOptRecovery,'LIP',aux1)
plotRecovery(data.trajOptRecovery,'LIPPFW',aux1)
plotRecovery(data.trajOptRecovery,'VHIP',aux1)
plotRecovery(data.trajOptRecovery,'VHIPPFW',aux1)


% Maximum recovery
plotRecovery(data.trajOptRecovery,'LIP',aux2)
plotRecovery(data.trajOptRecovery,'LIPPFW',aux2)
plotRecovery(data.trajOptRecovery,'VHIP',aux2)
plotRecovery(data.trajOptRecovery,'VHIPPFW',aux2)

%% Model Comparison

plotRelativeControl(data.trajOptRecovery.simData.VHIPPFW,"VHIPPFW",'figures\comparison\')
plotRelativeControl(data.trajOptRecovery.simData.VHIP,"VHIP",'figures\comparison\')
plotRelativeControl(data.trajOptRecovery.simData.LIPPFW,"LIPPFW",'figures\comparison\')


plotSolveTime([data.trajOptRecovery.simData.LIP.solverTime], [data.trajOptRecovery.simData.LIPPFW.solverTime],...
              [data.trajOptRecovery.simData.VHIP.solverTime], [data.trajOptRecovery.simData.VHIPPFW.solverTime], data.trajOptRecovery.simData.LIP(1).sim.time(end))

plotExcursion(data.trajOptRecovery.simData.LIP,data.trajOptRecovery.simData.LIPPFW,...
              data.trajOptRecovery.simData.VHIP,data.trajOptRecovery.simData.VHIPPFW)

plotPhase(data.trajOptRecovery.simData,100)          
plotPhase(data.trajOptRecovery.simData,300)
plotPhase(data.trajOptRecovery.simData,520)

%% compare COM position vs time of all models at LIP's max recover

spec = plotSpec();

f1 = figure('Position',[100 100 750 300])
hold all
plot(LIP(1,26).sim.time,LIP(1,26).sim.state(1,1:end),spec.LIP{:});
plot(LIPPFW(1,26).sim.time,LIPPFW(1,26).sim.state(1,1:end),spec.LIPPFW{:});
plot(VHIP(1,26).sim.time,VHIP(1,26).sim.state(1,1:end),spec.VHIP{:});
plot(VHIPPFW(1,26).sim.time,VHIPPFW(1,26).sim.state(1,1:end),spec.VHIPPFW{:});
xlabel('time [s]',spec.ltxFMT{:})
ylabel('$x$ [m]',spec.ltxFMT{:})
legend('LIP','LIPPFW','VHIP','VHIPPFW',spec.ltxFMT{:})
hold off


f2 = figure('Position',[100 100 750 300])
hold all
plot(LIP(1,end).sim.time,LIP(1,end).sim.state(1,1:end),spec.LIP{:});
plot(LIPPFW(1,end).sim.time,LIPPFW(1,end).sim.state(1,1:end),spec.LIPPFW{:});
plot(VHIP(1,end).sim.time,VHIP(1,end).sim.state(1,1:end),spec.VHIP{:});
plot(VHIPPFW(1,end).sim.time,VHIPPFW(1,end).sim.state(1,1:end),spec.VHIPPFW{:});
xlabel('time [s]',spec.ltxFMT{:})
ylabel('$x$ [m]',spec.ltxFMT{:})
legend('LIP','LIPPFW','VHIP','VHIPPFW',spec.ltxFMT{:})
hold off

exportgraphics(f1,'figures/trajOptSettleTimeLIPlim.png','Resolution',300)
exportgraphics(f2,'figures/trajOptSettleTimeMaxLim.png','Resolution',300)