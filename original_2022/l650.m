clc 
close all
clear all
syms r
A1=25*pi

for i=0.5:0.5:800;
    t=i;
    x=2*i;
    T(x)=t;
    r2=(5/sqrt(1+.000357*t));
    %%%0.000357=1.5/(70*60) 
    R(x)=r2;
   
    f=@(r) ((3.13.*(r*5/r2)+1042.7868)*(log(1+.000357.*t)).^(0.2015-0.0108.*(r*5/r2))).*2.*pi.*r;
    I=simpsons(f,0.5,r2,10*x);
    y(x)=I;

    ep=@(t) log(1+0.000357*t);
    Ep(x)=ep(t);
    
    a=@(r) pi*r^2;
    A(x)=a(r2);
    
    sigma(x)=y(x)/A(x);
    sigma2(x)=y(x)/A1;
    
    ep2=@(t) 0.025*t/70;
    Ep2(x)=ep2(t);
    
    displacment=@(t) 0.025*t;
    Displacement(x)=displacment(t);    
    
end
plot(T,y)
xlabel('Time(s)')
ylabel('force(N)')
figure 
plot(T,sigma)
xlabel('time(s)')
ylabel('true stress(MPa)')
figure
plot(T,Ep)
xlabel('time(s)')
ylabel('true strain')
figure
plot(T,sigma2)
xlabel('Time(s)')
ylabel('engineering stress(MPa)')
figure
plot(Ep,sigma)
xlabel('true strain')
ylabel('true stress(MPa)')
figure
plot(Ep2,sigma2)
xlabel('engineering strain')
ylabel('engineering stress(MPa)')
figure
plot(Displacement,y)
xlabel('displacment(mm)')
ylabel('Force(N)')
