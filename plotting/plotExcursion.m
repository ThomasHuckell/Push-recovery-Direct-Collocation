function [] = plotExcursion(LIP,LIPPFW,VHIP,VHIPPFW)

fntSize = 16;
g = 9.81;

spec = plotSpec();

ex_LIP      = zeros(3,length(LIP));
push_LIP    = zeros(1,length(LIP));

ex_LIPPFW   = zeros(3,length(LIPPFW));
push_LIPPFW    = zeros(1,length(LIPPFW));

ex_VHIP     = zeros(3,length(VHIP));
push_VHIP    = zeros(1,length(VHIP));

ex_VHIPPFW   = zeros(3,length(VHIPPFW));
push_VHIPPFW  = zeros(1,length(VHIPPFW));

for i = 1:length(LIP)
    ex_LIP(:,i) = LIP(i).excursion;
    push_LIP(i) = LIP(i).pushParam(1);
end

for i = 1:length(LIPPFW)
    ex_LIPPFW(:,i) = LIPPFW(i).excursion;
    push_LIPPFW(i) = LIPPFW(i).pushParam(1);
end

for i = 1:length(VHIP)
    ex_VHIP(:,i) = VHIP(i).excursion;  
    push_VHIP(i) = VHIP(i).pushParam(1);
end

for i = 1:length(VHIPPFW)
    ex_VHIPPFW(:,i) = VHIPPFW(i).excursion;
    push_VHIPPFW(i) = VHIPPFW(i).pushParam(1);        
end


f1 = figure('Position',[100 100 750 300]);
hold all
plot(push_LIP,ex_LIP(3,:),spec.LIP{:})
plot(push_LIPPFW,ex_LIPPFW(3,:),spec.LIPPFW{:})
plot(push_VHIP,ex_VHIP(3,:),spec.VHIP{:})
plot(push_VHIPPFW,ex_VHIPPFW(3,:),spec.VHIPPFW{:})
xlabel('Push Force [N]',spec.ltxFMT{:})
ylabel('\boldmath$\xi$ $_{\max}$',spec.ltxFMT{:})
legend('LIP','LIPPFW','VHIP','VHIPPFW','location','SouthEast',spec.ltxFMT{:})

exportgraphics(f1,'figures\comparison\model_MaxCP.png','Resolution',300)
end
