%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This programe is used to segment cardiomyocyte from the monolayer 
%   Reference: 
%   Copyright since 2019 by AMNL. All Rights Reserved.
%   E-mail: 
%   2019 Original Version by Qili Zhao
%   2019-10-07 Modified Version by Xingjian Liu, Wenkun Dou
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
clc;

Displacement = [];

cellNum=728;
imgNum=500;

T=1:imgNum;
T=T/1000;

aveNum=20;
aveDis=[];

for m = 1 : cellNum
    text_i1 = strcat('testingresults\Displacement\',num2str(m),'.txt');    
    Displacement(m,:)=load(text_i1);
    
    %filter the fasle points
      for k = 1 : imgNum
          if(Displacement(m,k) > 4 && k > 1)
              Displacement(m,k)=Displacement(m,k-1);
          end
      end
    % Fit the curve
    for k = 1 : imgNum
        Inik = max(1,k-aveNum/2);
        Endk = min(imgNum,k+aveNum/2);
        aveDis(m,k) = mean(Displacement(m,Inik:Endk));
    end
    
    cutNum=imgNum;
    figure(1);
    T1=T;
    plot(T1,aveDis(m,1:cutNum)-min(aveDis(m,:)),'r','LineWidth',2);
    %plot(T1,AveDis,'r','LineWidth',2);
    set(gca,'LineWidth',2);
    set(gca, 'Fontsize', 20);   
    % set(gca, 'XTick', []);                     % ??X?????
    set (gcf,'Position',[300,100,800,600], 'color','w');
    set(gca,'LineWidth',2);
%    set(gca,'ylim',[0,1.2]);
    ylabel('centroid displacement (\mum)','fontsize',30);%xxxx???
    xlabel('time (s)','fontsize',30);
    
    set(gca,'Fontname','Times New Roman','FontSize',30);
    path=strcat('DisplacementImage\',num2str(m),'.png');
    box off;
    print(gcf, '-dpng', '-r300', path);
end

k=1;