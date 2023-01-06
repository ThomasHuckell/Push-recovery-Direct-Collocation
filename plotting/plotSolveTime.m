
function plotSolveTime(t_LIP,t_LIPPFW,t_VHIP,t_VHIPPFW,t_sim)

spec = plotSpec();

xSim = categorical({'LIP','LIPPFW','VHIP','VHIPPFW'});
xSim = reordercats(xSim,{'LIP','LIPPFW','VHIP','VHIPPFW'});


Tsim = [mean(t_LIP) mean(t_LIPPFW) mean(t_VHIP) mean(t_VHIPPFW)];
Tstd = [std(t_LIP) std(t_LIPPFW) std(t_VHIP) std(t_VHIPPFW)];

f1 = figure();
b = bar(xSim,Tsim);
hold on

er = errorbar(Tsim,Tstd);
er.Color = [0 0 0];
er.LineStyle = 'none';

yline(t_sim,'--k','$T_{\textrm{sim}}$','interpreter','Latex');
hold off
b.FaceColor = 'flat';

b.CData(1,:) = hex2rgb(spec.LIP{2});
b.CData(2,:) = hex2rgb(spec.LIPPFW{2});
b.CData(3,:) = hex2rgb(spec.VHIP{2});
b.CData(4,:) = hex2rgb(spec.VHIPPFW{2});

ylabel('Processing Time [s]',spec.ltxFMT{:})

saveas(f1,'figures\comparison\compSolveTime.png')
end