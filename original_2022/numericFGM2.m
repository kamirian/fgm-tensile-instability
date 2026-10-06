clc 
close all
clear all
syms r
A1=25*pi
% f=@r ((10*r+100)*(log(1+.002*t))^(.1*sqrt(r)+.2))*2*pi*r
for i=0.5:0.5:400;
    t=i;
    x=2*i;
    T(x)=t;
    r2=(5/sqrt(1+.002*t));
    R(x)=r2;
    f=@(r) (100.*(log(1+.002.*t)).^0.3).*2.*pi.*r;
    %f=@(r) (100.*(log(1+.002.*t)).^0.3).*2.*pi.*(r*5/r2);
%     r2=(5/sqrt(1+.002*t));
%     R(x)=r2;
    I=simpsons(f,0,r2,10*x);
    y(x)=I;

    ep=@(t) log(1+0.002*t);
    Ep(x)=ep(t);
    
    a=@(r) pi*r^2;
    A(x)=a(r2);
    
    sigma(x)=y(x)/A(x);
    sigma2(x)=y(x)/A1;
    
    ep2=@(t) 0.2*t/100;
    Ep2(x)=ep2(t);
    
    displacment=@(t) 0.2*t;
    Displacement(x)=displacment(t);
    
    
    
    
    

    
%     for rr=0:r;
%         %si=@(rr) (10*rr+100)*(log(1+0.002*t))^0.34;
%         si=@(rr) (10*rr+100)*(log(1+0.002*t))^(.1.*sqrt(r)+.2);
%         Si(x)=si(rr);
        
%     end
%     N=@(r) 0.1*sqrt(r)+0.2;
%     I2=simpsons(N,0,r,10*x)
%     mitonim jaye r , 5 bezarim
%   ya inke mitonim ba A haye motenave hesab konim

    
    
    
end
plot(T,y)
xlabel('Time(s)')
ylabel('force(N)')
axis([0 400 0 4500])
figure 
plot(T,sigma)
xlabel('time(s)')
ylabel('true stress (MPa)')
figure
plot(T,Ep)
xlabel('time(s)')
ylabel('true strain')
figure
plot(T,sigma2)
xlabel('Time(s)')
ylabel('engineering stress (MPa)')
figure
plot(Ep,sigma)
xlabel('true strain')
ylabel('true stress (MPa')
figure
plot(Ep2,sigma2)
xlabel('engineering strain')
ylabel('engineering stress (MPa)')
figure
plot(Displacement,y)
xlabel('displacment(mm)')
ylabel('Force(N)')



