function [] = plotWork(LIP,LIPPFW,VHIP,VHIPPFW)



plotStruct = struct('LIP',[],'LIPPFW',[],'VHIP',[],'VHIPPFW',[]);


plotStruct.LIP =        extractData(LIP);
plotStruct.LIPPFW =     extractData(LIPPFW);
plotStruct.VHIP =       extractData(VHIP);
plotStruct.VHIPPFW =    extractData(VHIPPFW);



%total work vs push force
figure('Position',[100 100 750 300])
hold all
plot(plotStruct.LIP(:,1),plotStruct.LIP(:,5))
plot(plotStruct.LIPPFW(:,1),plotStruct.LIPPFW(:,5))
plot(plotStruct.VHIP(:,1),plotStruct.VHIP(:,5))
plot(plotStruct.VHIPPFW(:,1),plotStruct.VHIPPFW(:,5))
hold off
legend('LIP','LIPPFW','VHIP','VHIPPFW')
xlabel('Push force [N]')
ylabel('Total Mechanical Work [J]')

%
figure('Position',[100 100 750 300])
subplot(3,1,1)
hold all
plot(plotStruct.LIP(:,1),plotStruct.LIP(:,2))
plot(plotStruct.LIPPFW(:,1),plotStruct.LIPPFW(:,2))
plot(plotStruct.VHIP(:,1),plotStruct.VHIP(:,2))
plot(plotStruct.VHIPPFW(:,1),plotStruct.VHIPPFW(:,2))
hold off
legend('LIP','LIPPFW','VHIP','VHIPPFW','location','northwest')
xlabel('Push force [N]')
ylabel('Work [J]')
title('Ankle Work')

subplot(3,1,2)
hold all
plot(plotStruct.LIPPFW(:,1),plotStruct.LIPPFW(:,3))
plot(plotStruct.VHIPPFW(:,1),plotStruct.VHIPPFW(:,3))
hold off
legend('LIPPFW','VHIPPFW','location','northwest')
xlabel('Push force [N]')
ylabel('Work [J]')
title('Flywheel Work')

subplot(3,1,3)
hold all
plot(plotStruct.VHIP(:,1),plotStruct.VHIP(:,4))
plot(plotStruct.VHIPPFW(:,1),plotStruct.VHIPPFW(:,4))
hold off
legend('VHIP','VHIPPFW','location','northwest')
xlabel('Push force [N]')
ylabel('Work [J]')
title('Vertical Work')



    function workData = extractData(data)
        workData = zeros(length(data),5);
        
        for j = 1:length(data)
            workData(j,:) = [data(j).pushParam(1),data(j).work,sum(data(j).work)];
        end
        
        
    end

end
