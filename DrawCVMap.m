%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This programe is used to draw conduction velocity (CV) map based on the label-free method 
%   Reference: 
%   Copyright since 2019 by AMNL. All Rights Reserved.
%   E-mail: 
%   2019 Original Version by Qili Zhao
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;

% load cell position data
CellNum=728;
CellPos_x=[];
CellPos_y=[];
Cell_x=[];
Cell_y=[];

for m=1:1:CellNum
   text_ix1=strcat('testingresults\Res_x\',num2str(m),'.txt');
   text_iy1=strcat('testingresults\Res_y\',num2str(m),'.txt');  
    
   CellPos_x(m,:)=load(text_ix1);
   Cell_x=[Cell_x;mean(CellPos_x(m,:))];
   CellPos_y(m,:)=load(text_iy1);
   Cell_y=[Cell_y;mean(CellPos_y(m,:))];
end


% load delta T data obtained through cell beating curve
text_i2=strcat('testingresults\TT2\TT2.txt');
T2 = load(text_i2);

% Three level polynomial coefficients obtained through sftool according to T, Cell_x and Cell_y

P00 =   1.258;
P10 =   0.006008;
P01 =  -0.002298;
P20 =   7.578e-07;
P11 =  -1.704e-06;
P02 =   6.316e-06;
P30 =  -1.096e-09;
P21 =   2.632e-09;
P12 =  -2.836e-09;
P03 =  -1.019e-09;

TT2=[];
TT2 = P00 + P10*Cell_x + P01*Cell_y + P20*Cell_x.^2 + P11*Cell_x.*Cell_y + P02*Cell_y.^2 + P30*Cell_x.^3 + P21*(Cell_x.^2).*Cell_y+ P12*Cell_x.*(Cell_y.^2) + P03*Cell_y.^3; 
                    
Tx2=P10+2*P20*Cell_x+P11*Cell_y+3*P30*Cell_x.^2+2*P21*Cell_x.*Cell_y+P12*Cell_y.^2;
Ty2=P01+P11*Cell_x+2*P02*Cell_y+P21*Cell_x.^2+2*P12*Cell_x.*Cell_y+3*P03*Cell_y.^2;
Vx2=Tx2./(Tx2.^2+Ty2.^2);
Vy2=Ty2./(Tx2.^2+Ty2.^2);
V2=sqrt(Vx2.^2+Vy2.^2);
Angle2=atan(Vy2./Vx2)*180/pi;

%Draw CV map through calcium imaging
[xData, yData, zData] = prepareSurfaceData( Cell_x, Cell_y, TT2 );

% Set up fittype and options.
ft = fittype( 'poly33' );

% Fit model to data.
[fitresult, gof] = fit( [xData, yData], zData, ft );

% Make contour plot.
figure;
plot(fitresult, [xData, yData], zData);shading interp;
h = gca;
set(h, 'YDir', 'reverse');
view([0, 0, -90])

% Label axes
xlabel X;
ylabel Y;
grid off;
box off;
hold on;

quiver(Cell_x,Cell_y,Vx2,Vy2,'r','filled','LineWidth',1.5);
axis equal;



