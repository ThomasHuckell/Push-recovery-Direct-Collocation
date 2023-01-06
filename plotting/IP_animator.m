function M = IP_animator(data,param,model,fileName,aux)


g       = param.gravity; 
m       = param.mass;
delta   = param.supportSize;
z0      = param.restHeight;

pushForce   = data.pushParam(1);
pushDur     = data.pushParam(2);

state = data.sim.state;
control = data.sim.control;
time = data.sim.time;

spec = plotSpec();

CoMradius = 0.15;
fntSize   = 13;

xaxis = [-.75,0.75];
yaxis = [-0.1,1.4];

animateFlag = aux.flags.animate;
timeFrames  = aux.timeFrames;


%% generate time lapse plot

frameIndex = zeros(length(timeFrames),1);

traceHeight = zeros(length(timeFrames),2);


for i  = 1:length(timeFrames)
    [~,frameIndex(i)] = min(abs(data.sim.time-timeFrames(i)));
end



figure('Position',[100 100 1000 300]);

offset = .3;
ylim(yaxis);
xlim([-.4,length(timeFrames)*3/2*offset])
daspect([1 1 1])


hold on
c = 1;
for i = frameIndex'
    
    
    
    hold all
    stateOffset = state(:,i);
    stateOffset(1) = stateOffset(1) + (c-1)*3/2*offset;
    
    controlOffset = control(:,i);
    
    controlOffset(1) = controlOffset(1) +  (c-1)*3/2*offset;
    
    plotFrame(stateOffset,controlOffset,time(i),model,(c-1)*3/2*offset)        
            
    if model == "VHIP"
    
        traceHeight(c,:) = [stateOffset(1),stateOffset(2)];
    
    elseif model == "VHIPPFW"
        traceHeight(c,:) = [stateOffset(1),stateOffset(3)];
        
    else
        traceHeight(c,:) = [stateOffset(1),z0];
    end
            
    c = c + 1;
end

if model == "VHIP" || model == "VHIPPFW"
xx = 0:0.1:0.2+length(timeFrames)*3/2*offset;
yy = spline(traceHeight(:,1),traceHeight(:,2),xx);

hold on
plot(xx,yy,'--','Color','#B1B1B1')

else
   hold on
   plot(traceHeight(:,1),traceHeight(:,2),'--','Color','#B1B1B1')
 
end

ylabel('CoM height [m]',spec.ltxFMT{:})
set(gca,'XTick',[],'XTickLabel',[])

hold off

saveas(gcf,strcat(fileName,'timeLapse.png'));

%% video
    
if animateFlag == 1
h = figure;
axis manual

frameRate = 30;

t_end = min(aux.timeRange(2),data.sim.time(end));

movieFrameTime = 0:1/frameRate:t_end;
movieFrameIndex = zeros(1,length(movieFrameTime));


M(length(movieFrameIndex)) = struct('cdata',[],'colormap',[]);

for i = 1:length(movieFrameTime)
    
    [~,movieFrameIndex(i)] = min(abs(movieFrameTime(i)-data.sim.time));
    
end



        for i = 1:length(movieFrameIndex)
            
            c = movieFrameIndex(i);
            xlim(xaxis);
            ylim(yaxis);
            daspect([1,1,1]);
            
            plotFrame(state(:,c),control(:,c),time(c),model,0)
            

            M(i) = getframe(h);

            clf
            
        end
  
      


if nargin > 3
    fullFileName = strcat(fileName(1:end-1),'.avi');
    
    v = VideoWriter(fullFileName);
    v.FrameRate = 30;
    
    open(v);
    
    for i = 1:length(M)
        writeVideo(v,M(i));
    end
    
    close(v);
   
end

end

%% utility functions 

    function plotFrame(state,control,time,model,anklePos)
        
        
        switch model
            
            case 'LIP'
                
                CoP = [control,0];
                CoM = [state(1),z0];
                Push = CoM - 0.4*z0/(m*g)*pushForce*[1,0];
                
                
                hold all
                plot(delta+anklePos*[1,1],[0,0],'LineWidth',3,'Color','k','HandleVisibility','off')
                plot(xlim(),[0,0],'Color','#B1B1B1')
                if time <= pushDur
                    pushArrow(Push,CoM)
                end
                
                grfArrow(control,0,CoP,CoM);
                leg(anklePos,state(1),z0,'#808080',2);
                circ(state(1),z0,CoMradius,0);
                printTime(time,anklePos);
                
                drawnow
                hold off
                
                
                
            case 'LIPPFW'
                
                
                CoP = [control(1),0];
                CoM = [state(1),z0];
                Push = CoM - 0.4*z0/(m*g)*pushForce*[1,0];
                
                
                hold all
                plot(delta+anklePos*[1,1],[0,0],'LineWidth',3,'Color','k','HandleVisibility','off')
                plot(xlim(),[0,0],'Color','#B1B1B1')
                if time <= pushDur
                    pushArrow(Push,CoM)
                end
                grfArrow(control(1),0,CoP,CoM)
                leg(anklePos,state(1),z0,'#808080',2);
                circ(state(1),z0,CoMradius,state(2));
                torqueArrow(control(2),CoM);
                printTime(time,anklePos);
                
                drawnow
                hold off

                
            case 'VHIP'
                
                
                CoP = [control(1),0];
                CoM = [state(1),state(2)];
                Push = CoM - 0.4*z0/(m*g)*pushForce*[1,0];
                
                
                hold on
                plot(delta+anklePos*[1,1],[0,0],'LineWidth',3,'Color','k','HandleVisibility','off')
                plot(xlim(),[0,0],'Color','#B1B1B1')
                if time <= pushDur
                    pushArrow(Push,CoM)
                end
                
                
                leg(anklePos,state(1),state(2),'#808080',2);
                circ(state(1),state(2),CoMradius,0);
                accArrow(control(2),CoM);
                grfArrow(0,control(2),CoP,CoM);
                printTime(time,anklePos);
                
                drawnow
                hold off
                
                
            case 'VHIPPFW'
                
                CoP = [control(1),0];
                CoM = [state(1),state(3)];
                
                
                Push = CoM - 0.4*z0/(m*g)*pushForce*[1,0];
                
                
                hold all
                plot(delta+anklePos*[1,1],[0,0],'LineWidth',3,'Color','k','HandleVisibility','off')
                plot(xlim(),[0,0],'Color','#B1B1B1')
                if time <= pushDur
                    pushArrow(Push,CoM);
                end
                
                grfArrow(control(2),control(3),CoP,CoM);
                torqueArrow(control(2),CoM);
                leg(anklePos,state(1),state(3),'#808080',2);
                circ(state(1),state(3),CoMradius,state(2));
                
                accArrow(control(3),CoM);
                printTime(time,anklePos);
                
                drawnow
                hold off
  
        end
        
    end


    function circ(x,y,r,theta)
        
        th1 = -theta:pi/50:-theta+pi/2;
        x_circle1 = r * cos(th1) + x;
        y_circle1 = r * sin(th1) + y;
        plot(x_circle1, y_circle1,'k');
        
        th2 = -theta+pi/2:pi/50:-theta+pi;
        x_circle2 = r * cos(th2) + x;
        y_circle2 = r * sin(th2) + y;
        plot(x_circle2, y_circle2,'k');
        
        th3 = -theta+pi:pi/50:-theta+3/2*pi;
        x_circle3 = r * cos(th3) + x;
        y_circle3 = r * sin(th3) + y;
        plot(x_circle3, y_circle3,'k');
        
        th4 = -theta+3/2*pi:pi/50:-theta+2*pi;
        x_circle4 = r * cos(th4) + x;
        y_circle4 = r * sin(th4) + y;
        plot(x_circle4, y_circle4,'k');
        
        f1 = 1:length(x_circle1)+1;
        f2 = 1:length(x_circle3)+1;
        
        patch('Faces',f1,'Vertices',[[x,x_circle1]', [y,y_circle1]'],'FaceColor','black')
        patch('Faces',f2,'Vertices',[[x,x_circle3]', [y,y_circle3]'],'FaceColor','black')
        
        %fill([x,x_circle3], [y,y_circle3],'k')
        
        
    end

    function  leg(ankPos,com,height,color,width)
        
        X_pos = [ankPos com];
        Y_pos = [0 height];
        
        plot(X_pos,Y_pos,'Color',color,'LineWidth',width);
        
    end

    function torqueArrow(tau,CoM)
        

        hexColor = spec.hip{3};
        rgbColor = hex2rgb(hexColor);
        
        if abs(tau) <= 0.25
            return
        end
        thMax = -tau/param.tauMax*pi/2;
        
        th = linspace(0,thMax);
        
        x_arrow = CoM(1) + 0.18*cos(th);
        y_arrow = CoM(2) + 0.18*sin(th);
        
        
        x_head0 = [0;0.03;-0.03];
        y_head0 = [0.06*sign(thMax);0;0];
        
        R = [cos(thMax),-sin(thMax);
             sin(thMax),cos(thMax)];
         
        rot_head = [R*[x_head0(1);y_head0(1)] ,R*[x_head0(2);y_head0(2)],R*[x_head0(3);y_head0(3)]];
        
        x_head = [CoM(1) + 0.18*cos(thMax) + rot_head(1,:)];
        y_head = [CoM(2) + 0.18*sin(thMax) + rot_head(2,:)];
        
        plot(x_arrow,y_arrow,'Color',rgbColor,'LineWidth',2);
        patch('Faces', [1 2 3], 'Vertices', [x_head',y_head'] ,'EdgeColor',rgbColor,'FaceColor',rgbColor);
        
        text(x_head(1) + 0.05, y_head(1) + 0.05*sign(thMax), '$ \tau $','Color',hexColor, spec.ltxFMT{1:2},'FontSize',12)
        
    end

    function grfArrow(tau,zddot,CoP,CoM)
        
      
        hexColor = spec.ankle{3};
        
        r = CoP-CoM;
        
        fx = -(tau-r(1)*m*(g+zddot))/r(2);
        k = ((g+zddot)/g)*0.4*z0/(m*g);
        
        GRF = CoP + k*[fx,m*(g + zddot)];
       
        arrow3(CoP,GRF,'b1',0.8,0.8);
        
        plot(CoP(1),CoP(2),'o','color',hexColor,'MarkerFaceColor',hexColor);
        text(CoP(1)+0.05,CoP(2)-0.05,'$x_c$','Color',hexColor,spec.ltxFMT{1:2},'FontSize',12)
        text(GRF(1)+0.05,GRF(2) -0.1,'$f_{gr}$',spec.ltxFMT{1:2},'FontSize',12)
        
    end

    function accArrow(zddot,CoM)
        
        
        
        if abs(zddot) <= 0.05
            return
        end
       
        
        hexColor = spec.toe{3};
        rgbColor = hex2rgb(hexColor);
        
        mag = zddot/param.zddot*1.5*CoMradius;
        point = CoM + mag*[0,1];
        
        tail_x = [CoM(1); point(1)];
        tail_y = [CoM(2); point(2)];
        arrow_x = [CoM(1)+0.03; CoM(1); CoM(1)-0.03];
        arrow_y = [point(2); point(2)+ sign(mag)*0.06; point(2)];
        plot(tail_x,tail_y,'LineWidth',2,'Color',hexColor)
        patch('Faces', [1 2 3], 'Vertices', [arrow_x,arrow_y] ,'EdgeColor',rgbColor,'FaceColor',rgbColor);
        
        text(point(1) + 0.075 ,point(2)+sign(mag)*0.05,'$\ddot{z}$','Color',hexColor,spec.ltxFMT{1:2},'FontSize',12)
        
        
        
    end

    function pushArrow(Push,CoM)
        arrow3(Push,CoM,'r',0.8,0.8);
        
        text(CoM(1)-1.5*CoMradius ,Push(2) + 0.1, '$f_{ext}$','Color','red' ,spec.ltxFMT{:})
    end

    function printTime(time,pos)
        gcf
        
        axY = ylim();
        axX = xlim();
        
        if axX(2) <= 1
            pos = 0.6*axX(2);
        end
       
         
        timeLabelPos = [pos-1.05*CoMradius,0.95*axY(2)];
       
     
            
        text(timeLabelPos(1),timeLabelPos(2), strcat("t = ",num2str(time,'%.2f'),"s"),'FontSize',8,'FontWeight','bold')
    end


end



