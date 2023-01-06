function [X,U,T] = trapInt(x,u,p,time)
% trapInt interpolates the states and controls between the collocation
% points

Dyn = p.dynamics;

N = p.knot.points;
n = p.knot.pushPoints;
nInt = 20;

xSize = p.pack.xSize(1);
uSize = p.pack.uSize(1);


f = p.push.force;

X = zeros(xSize,(nInt-1)*(N-1)+1);
U = zeros(uSize,(nInt-1)*(N-1)+1);
T = zeros(1,(nInt-1)*(N-1)+1);


for i = 1:n-1
    
    tInt = linspace(time(i),time(i+1),nInt);
    
    uInt = zeros(uSize,nInt);
    xInt = zeros(xSize,nInt);
    
    for j = 1:uSize
    
    uInt(j,:) = interp1([time(i) time(i+1)],[u(j,i) u(j,i+1)], tInt);
           
    end
    
    
    U(:,(i-1)*(nInt-1)+1:i*(nInt-1)) = uInt(:,1:nInt-1);
    T((i-1)*(nInt-1)+1:i*(nInt-1)) = tInt(1:nInt-1);
    

    for j = 1:nInt 
        
        tau = tInt(j)-time(i);
        h   = time(i+1) - time(i);
        
        Dxm = Dyn(x(:,i),u(:,i),p,f);
        
        Dxp = Dyn(x(:,i+1),u(:,i+1),p,f);
        
        xInt(:,j) = x(:,i) + Dxm*tau + tau^2/(2*h)*(Dxp - Dxm);
        
        
    end
    
     X(:,(i-1)*(nInt-1)+1:i*(nInt-1)) = xInt(:,1:nInt-1);
    
end

for i = n:N-1
    
    tInt = linspace(time(i),time(i+1),nInt);
    
    uInt = zeros(uSize,nInt);
    xInt = zeros(xSize,nInt);
    
    for j = 1:uSize
    
    uInt(j,:) = interp1([time(i) time(i+1)],[u(j,i) u(j,i+1)], tInt);
           
    end
    
    U(:,(i-1)*(nInt-1)+1:i*(nInt-1)) = uInt(:,1:nInt-1);
    T((i-1)*(nInt-1)+1:i*(nInt-1)) = tInt(1:nInt-1);
    
    for j = 1:nInt 
        
        tau = tInt(j)-time(i);
        h   = time(i+1) - time(i);
        
        Dxm = Dyn(x(:,i),u(:,i),p,0);
        
        Dxp = Dyn(x(:,i+1),u(:,i+1),p,0);
        
        xInt(:,j) = x(:,i) + Dxm*tau + tau^2/(2*h)*(Dxp - Dxm);
        
        
    end
    
     X(:,(i-1)*(nInt-1)+1:i*(nInt-1)) = xInt(:,1:nInt-1);
    
end

X(:,end) = x(:,end);
U(:,end) = u(:,end);
T(:,end) = time(end);
end