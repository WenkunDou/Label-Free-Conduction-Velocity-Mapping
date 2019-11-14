%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This programe is used to draw the cell motion trajectory from displacment 
%   Reference: 
%   Copyright since 2019 by AMNL. All Rights Reserved.
%   E-mail: 
%   2019 Original Version by Qili Zhao
%   2019-10-07 Modified Version by Xingjian Liu, Wenkun Dou
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
clc;


cellNum=728;
imgNum=500;

CellPos_x = [];
CellPos_y = [];
deltaRes_x = [];
deltaRes_y = [];
aveDeltaRes_x = [];
aveDeltaRes_y = [];

display('--------------------------------------------------------')
display('Loading the cell displacement data!')
display('--------------------------------------------------------')

%load the saved cell movement data
for m=1:cellNum
    text_i1=strcat('testingresults\deltaPos_x\',num2str(m),'.txt');
    text_i2=strcat('testingresults\deltaPos_y\',num2str(m),'.txt');
    
    CellPos_x(m,:)=load(text_i1);
    CellPos_y(m,:)=load(text_i2);
    
    ave_x=mean(CellPos_x(m,1:50));
    ave_y=mean(CellPos_y(m,1:50));
    
    deltaRes_x(m,:)=CellPos_x(m,:)-ave_x;
    deltaRes_y(m,:)=CellPos_y(m,:)-ave_y;
end


display('--------------------------------------------------------')
display('Draw the Trajectory and save to image file!')
display('--------------------------------------------------------')

aveNum=30;
maxBeat=[];
for m = 1 : cellNum
    for k = 1 : 1 : imgNum
      k1 = max([1,k-aveNum/2]);
      k2 = min([k+aveNum/2,imgNum]);
      aveDeltaRes_x(m,k) = mean(deltaRes_x(m,k1:k2));
      aveDeltaRes_y(m,k) = mean(deltaRes_y(m,k1:k2));      
    end
    display(strcat('Now, processing cell_',num2str(m), ' total cell number:', num2str(cellNum) ))
    
    dis=sqrt((aveDeltaRes_x(m,:)*1320/896).^2+(aveDeltaRes_y(m,:)*1320/896).^2);
    a = max(dis);
    cutNum = imgNum;
    maxBeat=[maxBeat;a];
    figure(1);
    plot(aveDeltaRes_x(m,1:cutNum)*1320/896,aveDeltaRes_y(m,1:cutNum)*1320/896,'b-o');
    xlabel('X_c_e_l_l (\mum)','fontsize',20);
    ylabel('Y_c_e_l_l (\mum)','fontsize',20);
    %axis equal;
    axis tight;
    set (gcf,'Position',[300,100,800,600], 'color','w');
    %set(gca,'ylim',[-0.5,1.5]);
    set(gca,'LineWidth',2);
    set(gca,'Fontname','Times New Roman','FontSize',30);
    Image_i2=strcat('TrajectoryImage\',num2str(m),'.jpg');
    set(gca,'Fontname','Times New Roman','FontSize',30); 
    box off;
    print(gcf, '-dpng', '-r300', Image_i2);
    k=m;
end

